defmodule CosmeticsSystem.Procurement.PurchaseOrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "purchase_order_items" do
    field :quantity, :integer, default: 0
    field :unit_cost, :decimal
    field :received_quantity, :integer, default: 0

    belongs_to :purchase_order, CosmeticsSystem.Procurement.PurchaseOrder
    belongs_to :product, CosmeticsSystem.Catalog.Product
    belongs_to :variant, CosmeticsSystem.Catalog.ProductVariant, foreign_key: :variant_id

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :quantity,
      :unit_cost,
      :received_quantity,
      :purchase_order_id,
      :product_id,
      :variant_id
    ])
    |> validate_required([:quantity, :unit_cost, :purchase_order_id, :product_id])
    |> validate_number(:quantity, greater_than: 0)
  end
end
