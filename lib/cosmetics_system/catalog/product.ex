defmodule CosmeticsSystem.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field :name, :string
    field :slug, :string
    field :sku, :string
    field :description, :string
    field :ingredients, :string
    field :how_to_use, :string
    field :base_price, :decimal
    field :compare_at_price, :decimal
    field :cost_price, :decimal
    field :active, :boolean, default: true
    field :featured, :boolean, default: false
    field :tags, {:array, :string}, default: []

    belongs_to :category, CosmeticsSystem.Catalog.Category
    belongs_to :supplier, CosmeticsSystem.Procurement.Supplier
    has_many :variants, CosmeticsSystem.Catalog.ProductVariant, on_delete: :delete_all
    has_many :images, CosmeticsSystem.Catalog.ProductImage, on_delete: :delete_all

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :slug,
      :sku,
      :description,
      :ingredients,
      :how_to_use,
      :base_price,
      :compare_at_price,
      :cost_price,
      :active,
      :featured,
      :tags,
      :category_id,
      :supplier_id
    ])
    |> validate_required([:name, :sku, :base_price])
    |> validate_number(:base_price, greater_than: 0)
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
    |> unique_constraint(:sku)
  end

  def effective_price(%__MODULE__{base_price: price}), do: price

  defp maybe_generate_slug(changeset) do
    if get_change(changeset, :name) && !get_change(changeset, :slug) do
      put_change(changeset, :slug, CosmeticsSystem.Slug.slugify(get_change(changeset, :name)))
    else
      changeset
    end
  end
end
