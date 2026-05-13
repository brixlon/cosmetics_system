defmodule CosmeticsSystem.Procurement.PurchaseOrder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "purchase_orders" do
    field :number, :string
    field :status, :string, default: "draft"

    belongs_to :supplier, CosmeticsSystem.Procurement.Supplier

    timestamps()
  end

  def changeset(po, attrs) do
    po
    |> cast(attrs, [:number, :status, :supplier_id])
    |> validate_required([:supplier_id])
  end
end
