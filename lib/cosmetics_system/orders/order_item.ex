defmodule CosmeticsSystem.Orders.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "order_items" do
    field :product_name, :string
    field :variant_name, :string
    field :quantity, :integer, default: 1
    field :unit_price, :decimal
    field :line_total, :decimal

    belongs_to :order, CosmeticsSystem.Orders.Order
    belongs_to :product, CosmeticsSystem.Catalog.Product
    belongs_to :product_variant, CosmeticsSystem.Catalog.ProductVariant, foreign_key: :variant_id

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :product_name,
      :variant_name,
      :quantity,
      :unit_price,
      :line_total,
      :order_id,
      :product_id,
      :variant_id
    ])
    |> validate_required([
      :quantity,
      :unit_price,
      :line_total,
      :order_id,
      :product_id,
      :product_name
    ])
    |> validate_number(:quantity, greater_than: 0)
  end
end
