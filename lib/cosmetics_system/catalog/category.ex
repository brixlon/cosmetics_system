defmodule CosmeticsSystem.Catalog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :position, :integer, default: 0
    field :active, :boolean, default: true

    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :subcategories, __MODULE__, foreign_key: :parent_id
    has_many :products, CosmeticsSystem.Catalog.Product

    timestamps()
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description, :position, :active, :parent_id])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    if get_change(changeset, :name) && !get_change(changeset, :slug) do
      name = get_change(changeset, :name)
      put_change(changeset, :slug, CosmeticsSystem.Slug.slugify(name))
    else
      changeset
    end
  end
end
