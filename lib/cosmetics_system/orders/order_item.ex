defmodule CosmeticsSystem.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "order_items" do
    field :quantity, :integer, default: 1
    field :unit_price, :decimal

    belongs_to :order, CosmeticsSystem.Orders.Order
    belongs_to :product_variant, CosmeticsSystem.Catalog.ProductVariant

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:quantity, :unit_price, :order_id, :product_variant_id])
    |> validate_required([:quantity, :unit_price, :order_id, :product_variant_id])
    |> validate_number(:quantity, greater_than: 0)
  end
end
