defmodule CosmeticsSystem.Orders do
  @moduledoc """
  The Orders context — cart, checkout, payments.
  """
  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.Orders.{Order, OrderItem, Payment}
  alias CosmeticsSystem.Catalog
  alias CosmeticsSystem.CRM

  def list_orders(opts \\ []) do
    Order
    |> apply_order_filters(opts)
    |> order_by([o], desc: o.inserted_at)
    |> maybe_limit(opts[:limit])
    |> preload([:customer, :items])
    |> Repo.all()
  end

  def get_order!(id),
    do: Repo.get!(Order, id) |> Repo.preload([:customer, :items, :payments, :shipping_address])

  def get_order_by_number!(number),
    do: Repo.get_by!(Order, number: number) |> Repo.preload([:customer, :items, :payments])

  @doc """
  Creates an order from a cart (list of %{variant_id, quantity} maps).
  Wraps stock deduction, order creation, and loyalty award in a transaction.
  """
  def create_order(customer_id, cart_items, opts \\ []) do
    Repo.transaction(fn ->
      customer = CRM.get_customer!(customer_id)

      items_with_prices =
        Enum.map(cart_items, fn %{variant_id: vid, quantity: qty} ->
          variant = Catalog.get_variant!(vid) |> Repo.preload(:product)

          if variant.stock_quantity < qty do
            Repo.rollback({:insufficient_stock, variant.product.name})
          end

          line_total = Decimal.mult(variant.product.base_price, qty)

          %{
            variant: variant,
            quantity: qty,
            unit_price: variant.product.base_price,
            line_total: line_total
          }
        end)

      subtotal = Enum.reduce(items_with_prices, Decimal.new(0), &Decimal.add(&2, &1.line_total))
      tax = Decimal.mult(subtotal, "0.16")
      shipping = opts[:shipping_fee] || Decimal.new("250.00")
      total = Decimal.add(subtotal, tax) |> Decimal.add(shipping)

      {:ok, order} =
        %Order{}
        |> Order.changeset(%{
          customer_id: customer.id,
          shipping_address_id:
            opts[:address_id] ||
              case CRM.get_default_address(customer.id) do
                nil -> nil
                addr -> addr.id
              end,
          subtotal: subtotal,
          tax_amount: tax,
          shipping_fee: shipping,
          total: total,
          notes: opts[:notes]
        })
        |> Repo.insert()

      Enum.each(items_with_prices, fn %{variant: v, quantity: qty, unit_price: up, line_total: lt} ->
        %OrderItem{}
        |> Ecto.Changeset.cast(
          %{
            order_id: order.id,
            product_id: v.product_id,
            variant_id: v.id,
            product_name: v.product.name,
            variant_name: v.name,
            quantity: qty,
            unit_price: up,
            line_total: lt
          },
          [
            :order_id,
            :product_id,
            :variant_id,
            :product_name,
            :variant_name,
            :quantity,
            :unit_price,
            :line_total
          ]
        )
        |> Repo.insert!()

        {:ok, _} = Catalog.adjust_stock(v, -qty)
      end)

      points_earned = Decimal.to_integer(Decimal.round(total))
      CRM.award_loyalty_points(customer, points_earned)

      Repo.preload(order, [:items])
    end)
  end

  def update_order_status(%Order{} = order, status) do
    order
    |> Order.changeset(%{status: status})
    |> Repo.update()
    |> tap(fn {:ok, o} ->
      Phoenix.PubSub.broadcast(CosmeticsSystem.PubSub, "orders", {:order_updated, o})
    end)
  end

  def record_payment(order_id, attrs) do
    %Payment{}
    |> Ecto.Changeset.cast(
      Map.put(attrs, :order_id, order_id),
      [:order_id, :provider, :provider_ref, :amount, :currency, :status, :metadata]
    )
    |> Repo.insert()
    |> case do
      {:ok, payment} ->
        if payment.status == "succeeded" do
          get_order!(order_id) |> update_order_status("processing")

          from(o in Order, where: o.id == ^order_id)
          |> Repo.update_all(set: [payment_status: "paid"])
        end

        {:ok, payment}

      error ->
        error
    end
  end

  def order_stats do
    today = Date.utc_today()
    month_start = Date.beginning_of_month(today)
    yesterday = Date.add(today, -1)

    today_rev = today_revenue(today)
    yesterday_rev = today_revenue(yesterday)
    month_rev = month_revenue(month_start)
    prev_month_slice = previous_month_mtd_slice(today, month_start)

    %{
      total_orders: Repo.aggregate(Order, :count),
      pending: Repo.aggregate(from(o in Order, where: o.status == "pending"), :count),
      pending_urgent: pending_urgent_count(),
      today_revenue: today_rev,
      today_revenue_trend: revenue_trend_vs("yesterday", today_rev, yesterday_rev),
      month_revenue: month_rev,
      month_revenue_trend: revenue_trend_vs("same period last month", month_rev, prev_month_slice)
    }
  end

  defp pending_urgent_count do
    cutoff = NaiveDateTime.utc_now() |> NaiveDateTime.add(-48 * 3600, :second)

    Repo.aggregate(
      from(o in Order, where: o.status == "pending" and o.inserted_at < ^cutoff),
      :count
    )
  end

  defp previous_month_mtd_slice(today, month_start) do
    prev_month_first = month_start |> Date.add(-1) |> Date.beginning_of_month()
    span_days = Date.diff(today, month_start)
    proposed_end = Date.add(prev_month_first, span_days)
    prev_end = min_date(proposed_end, Date.end_of_month(prev_month_first))
    sum_revenue_inclusive_dates(prev_month_first, prev_end)
  end

  defp min_date(a, b) do
    case Date.compare(a, b) do
      :gt -> b
      _ -> a
    end
  end

  defp sum_revenue_inclusive_dates(%Date{} = from_date, %Date{} = to_date) do
    start_ndt = NaiveDateTime.new!(from_date, ~T[00:00:00])
    end_ndt = NaiveDateTime.new!(to_date, ~T[23:59:59])

    from(o in Order,
      where:
        o.payment_status == "paid" and o.inserted_at >= ^start_ndt and o.inserted_at <= ^end_ndt,
      select: sum(o.total)
    )
    |> Repo.one() || Decimal.new(0)
  end

  defp revenue_trend_vs(vs_label, current, previous) do
    cond do
      Decimal.compare(current, previous) == :eq ->
        "Flat vs #{vs_label}"

      Decimal.equal?(previous, 0) ->
        if Decimal.equal?(current, 0) do
          "No paid orders (#{vs_label})"
        else
          "Up from zero #{vs_label}"
        end

      true ->
        pct =
          current
          |> Decimal.sub(previous)
          |> Decimal.div(previous)
          |> Decimal.mult(100)
          |> Decimal.round(0)
          |> Decimal.to_integer()

        dir = if pct >= 0, do: "Up", else: "Down"
        "#{dir} #{abs(pct)}% vs #{vs_label}"
    end
  end

  defp today_revenue(date) do
    from(o in Order,
      where: o.payment_status == "paid" and fragment("DATE(?)", o.inserted_at) == ^date,
      select: sum(o.total)
    )
    |> Repo.one() || Decimal.new(0)
  end

  defp month_revenue(from_date) do
    from(o in Order,
      where:
        o.payment_status == "paid" and
          o.inserted_at >= ^NaiveDateTime.new!(from_date, ~T[00:00:00]),
      select: sum(o.total)
    )
    |> Repo.one() || Decimal.new(0)
  end

  defp apply_order_filters(query, opts) do
    query
    |> then(fn q -> if s = opts[:status], do: where(q, [o], o.status == ^s), else: q end)
    |> then(fn q ->
      if c = opts[:customer_id], do: where(q, [o], o.customer_id == ^c), else: q
    end)
    |> then(fn q ->
      case opts[:date_range] do
        {from, to} -> where(q, [o], o.inserted_at >= ^from and o.inserted_at <= ^to)
        _ -> q
      end
    end)
  end

  defp maybe_limit(query, nil), do: query
  defp maybe_limit(query, lim), do: limit(query, ^lim)
end
