defmodule CosmeticsSystem.Procurement do
  @moduledoc """
  The Procurement context — suppliers and purchase orders.
  """
  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.Procurement.{Supplier, PurchaseOrder, PurchaseOrderItem}

  # ── Suppliers ───────────────────────────────────────────────────────

  def list_suppliers(opts \\ []) do
    Supplier
    |> then(fn q -> if opts[:active_only], do: where(q, [s], s.active == true), else: q end)
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  def get_supplier!(id), do: Repo.get!(Supplier, id) |> Repo.preload(:products)
  def create_supplier(attrs), do: %Supplier{} |> Supplier.changeset(attrs) |> Repo.insert()

  def update_supplier(%Supplier{} = supplier, attrs),
    do: supplier |> Supplier.changeset(attrs) |> Repo.update()

  def change_supplier(%Supplier{} = supplier, attrs \\ %{}),
    do: Supplier.changeset(supplier, attrs)

  def change_purchase_order(%PurchaseOrder{} = po, attrs \\ %{}),
    do: PurchaseOrder.changeset(po, attrs)

  def update_purchase_order(%PurchaseOrder{} = po, attrs),
    do: po |> PurchaseOrder.changeset(attrs) |> Repo.update()

  def create_purchase_order_header(attrs) do
    %PurchaseOrder{}
    |> PurchaseOrder.changeset(attrs)
    |> Repo.insert()
  end

  # ── Purchase Orders ─────────────────────────────────────────────────

  def list_purchase_orders(opts \\ []) do
    PurchaseOrder
    |> then(fn q -> if s = opts[:status], do: where(q, [po], po.status == ^s), else: q end)
    |> order_by([po], desc: po.inserted_at)
    |> preload([:supplier, :items])
    |> Repo.all()
  end

  def get_purchase_order!(id),
    do: Repo.get!(PurchaseOrder, id) |> Repo.preload([:supplier, :items, :employee])

  def create_purchase_order(attrs, items) do
    Repo.transaction(fn ->
      total =
        Enum.reduce(items, Decimal.new(0), fn item, acc ->
          Decimal.add(acc, Decimal.mult(item.unit_cost, item.quantity))
        end)

      {:ok, po} =
        %PurchaseOrder{}
        |> PurchaseOrder.changeset(Map.put(attrs, :total_amount, total))
        |> Repo.insert()

      Enum.each(items, fn item ->
        %PurchaseOrderItem{}
        |> Ecto.Changeset.cast(Map.put(item, :purchase_order_id, po.id), [
          :purchase_order_id,
          :product_id,
          :variant_id,
          :quantity,
          :unit_cost,
          :received_quantity
        ])
        |> Repo.insert!()
      end)

      po
    end)
  end

  def receive_purchase_order(%PurchaseOrder{} = po) do
    Repo.transaction(fn ->
      Enum.each(po.items, fn item ->
        CosmeticsSystem.Catalog.adjust_stock_by_product(
          item.product_id,
          item.variant_id,
          item.quantity
        )
      end)

      po
      |> Ecto.Changeset.change(%{status: "received", received_at: NaiveDateTime.utc_now()})
      |> Repo.update!()
    end)
  end

  def pending_deliveries do
    PurchaseOrder
    |> where([po], po.status in ["ordered", "in_transit"])
    |> where([po], po.expected_delivery <= ^Date.utc_today())
    |> preload(:supplier)
    |> Repo.all()
  end
end
