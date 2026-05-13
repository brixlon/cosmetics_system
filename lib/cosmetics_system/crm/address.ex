defmodule CosmeticsSystem.CRM.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "addresses" do
    field :label, :string, default: "home"
    field :line1, :string
    field :line2, :string
    field :city, :string
    field :state, :string
    field :postal_code, :string
    field :country, :string, default: "KE"
    field :is_default, :boolean, default: false

    belongs_to :customer, CosmeticsSystem.CRM.Customer

    timestamps()
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [
      :label,
      :line1,
      :line2,
      :city,
      :state,
      :postal_code,
      :country,
      :is_default,
      :customer_id
    ])
    |> validate_required([:line1, :city, :country, :customer_id])
  end
end
