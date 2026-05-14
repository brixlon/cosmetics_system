defmodule CosmeticsSystemWeb.Admin.DashboardLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.{Orders, Catalog, CRM, HR}

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(CosmeticsSystem.PubSub, "orders")

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign_stats()}
  end

  @impl true
  def handle_info({:order_updated, _order}, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp kpi_card(assigns) do
    ~H"""
    <div class={"kpi-card kpi-card--#{@color}"}>
      <div class="kpi-accent"></div>
      <div class="kpi-icon-wrap">
        <.icon name={@icon} class="kpi-icon" />
      </div>
      <div class="kpi-body">
        <p class="kpi-value">{@value}</p>
        <p class="kpi-label">{@label}</p>
        <p class="kpi-trend">{@trend}</p>
      </div>
    </div>
    """
  end

  defp stock_bar(assigns) do
    pct = min(trunc(assigns.quantity / max(assigns.threshold, 1) * 100), 100)

    color =
      cond do
        pct <= 20 -> "var(--color-danger)"
        pct <= 40 -> "var(--color-warning)"
        true -> "var(--color-success)"
      end

    assigns = assign(assigns, pct: pct, bar_color: color)

    ~H"""
    <div class="stock-bar-wrap">
      <div class="stock-bar-bg">
        <div
          class="stock-bar-fill"
          style={"width: #{@pct}%; background: #{@bar_color};"}
        >
        </div>
      </div>
      <span class="stock-qty">{@quantity} / {@threshold}</span>
    </div>
    """
  end

  defp assign_stats(socket) do
    order_stats = Orders.order_stats()
    low_stock = Catalog.low_stock_products()
    customers = CRM.list_customers()
    employees = HR.list_employees(active_only: true)
    week_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-7, :day)

    socket
    |> assign(:stats, %{
      today_revenue: order_stats.today_revenue,
      today_revenue_trend: order_stats.today_revenue_trend,
      month_revenue: order_stats.month_revenue,
      month_revenue_trend: order_stats.month_revenue_trend,
      pending: order_stats.pending,
      pending_urgent: order_stats.pending_urgent,
      total_customers: length(customers),
      new_customers_week: CRM.count_customers_inserted_since(week_ago),
      low_stock_count: length(low_stock),
      active_staff: length(employees),
      staff_on_leave: HR.staff_on_leave_count()
    })
    |> assign(:recent_orders, Orders.list_orders(limit: 10))
    |> assign(:low_stock, low_stock)
  end

  defp format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  defp format_number(n) when is_float(n), do: format_number(trunc(n))

  defp format_number(%Decimal{} = d) do
    d
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> format_number()
  end

  defp format_number(nil), do: "0"
end
