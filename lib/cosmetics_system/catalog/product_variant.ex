defmodule CosmeticsSystem.Catalog.ProductVariant do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "product_variants" do
    field :name, :string
    field :sku, :string
    field :shade, :string
    field :size, :string
    field :fragrance, :string
    field :price_modifier, :decimal, default: 0
    field :stock_quantity, :integer, default: 0
    field :low_stock_threshold, :integer, default: 10
    field :active, :boolean, default: true

    belongs_to :product, CosmeticsSystem.Catalog.Product

    timestamps()
  end

  def changeset(variant, attrs) do
    variant
    |> cast(attrs, [
      :name,
      :sku,
      :shade,
      :size,
      :fragrance,
      :price_modifier,
      :stock_quantity,
      :low_stock_threshold,
      :active,
      :product_id
    ])
    |> validate_required([:name, :sku, :product_id])
    |> unique_constraint(:sku)
  end

  def low_stock?(%__MODULE__{stock_quantity: qty, low_stock_threshold: threshold}) do
    qty <= threshold
  end

  def out_of_stock?(%__MODULE__{stock_quantity: qty}), do: qty <= 0

  def deduct_stock(variant, quantity) do
    new_qty = max(0, variant.stock_quantity - quantity)
    change(variant, stock_quantity: new_qty)
  end
end
