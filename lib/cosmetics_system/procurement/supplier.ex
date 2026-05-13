defmodule CosmeticsSystem.Procurement.Supplier do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "suppliers" do
    field :name, :string
    field :contact_name, :string
    field :email, :string
    field :phone, :string
    field :website, :string
    field :country, :string
    field :address, :string
    field :payment_terms, :string
    field :notes, :string
    field :active, :boolean, default: true

    has_many :products, CosmeticsSystem.Catalog.Product
    has_many :purchase_orders, CosmeticsSystem.Procurement.PurchaseOrder

    timestamps()
  end

  def changeset(supplier, attrs) do
    supplier
    |> cast(attrs, [
      :name,
      :contact_name,
      :email,
      :phone,
      :website,
      :country,
      :address,
      :payment_terms,
      :notes,
      :active
    ])
    |> validate_required([:name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
  end
end
