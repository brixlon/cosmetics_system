defmodule CosmeticsSystem.CRM do
  @moduledoc """
  The CRM context — customers, addresses, loyalty.
  """
  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.CRM.{Customer, Address}

  def list_customers(opts \\ []) do
    Customer
    |> apply_customer_filters(opts)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  def get_customer!(id), do: Repo.get!(Customer, id) |> Repo.preload([:user, :addresses])

  def get_customer_by_user_id(user_id),
    do: Repo.get_by(Customer, user_id: user_id) |> Repo.preload([:addresses])

  def create_customer(attrs) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  def award_loyalty_points(%Customer{} = customer, points) do
    customer
    |> Customer.add_points(points)
    |> Repo.update()
  end

  def customers_by_tier do
    Customer
    |> group_by([c], c.loyalty_tier)
    |> select([c], {c.loyalty_tier, count(c.id)})
    |> Repo.all()
    |> Map.new()
  end

  def count_customers_inserted_since(%NaiveDateTime{} = since) do
    from(c in Customer, where: c.inserted_at >= ^since, select: count(c.id))
    |> Repo.one()
  end

  def top_customers(limit \\ 10) do
    from(c in Customer,
      join: o in assoc(c, :orders),
      where: o.payment_status == "paid",
      group_by: c.id,
      order_by: [desc: sum(o.total)],
      select: %{customer: c, total_spent: sum(o.total)},
      limit: ^limit
    )
    |> Repo.all()
  end

  # ── Addresses ───────────────────────────────────────────────────────

  def list_addresses(customer_id) do
    Address
    |> where([a], a.customer_id == ^customer_id)
    |> Repo.all()
  end

  def create_address(attrs) do
    Repo.transaction(fn ->
      with {:ok, address} <- %Address{} |> Address.changeset(attrs) |> Repo.insert() do
        if attrs[:is_default] do
          from(a in Address,
            where: a.customer_id == ^address.customer_id and a.id != ^address.id
          )
          |> Repo.update_all(set: [is_default: false])
        end

        address
      end
    end)
  end

  def get_default_address(customer_id) do
    Repo.get_by(Address, customer_id: customer_id, is_default: true)
  end

  defp apply_customer_filters(query, opts) do
    query
    |> then(fn q -> if t = opts[:tier], do: where(q, [c], c.loyalty_tier == ^t), else: q end)
    |> then(fn q ->
      if s = opts[:search] do
        term = "%#{s}%"
        where(q, [c], ilike(c.first_name, ^term) or ilike(c.last_name, ^term))
      else
        q
      end
    end)
  end
end
