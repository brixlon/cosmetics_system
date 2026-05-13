defmodule CosmeticsSystem.Catalog.ProductImage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "product_images" do
    field :url, :string
    field :position, :integer, default: 0

    belongs_to :product, CosmeticsSystem.Catalog.Product

    timestamps()
  end

  def changeset(image, attrs) do
    image
    |> cast(attrs, [:url, :position, :product_id])
    |> validate_required([:url, :product_id])
  end
end
