defmodule CosmeticsSystem.Catalog.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "product_images" do
    field :url, :string
    field :alt_text, :string
    field :position, :integer, default: 0
    field :is_primary, :boolean, default: false

    belongs_to :product, CosmeticsSystem.Catalog.Product

    timestamps()
  end

  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :alt_text, :position, :is_primary, :product_id])
    |> validate_required([:url, :product_id])
  end
end
