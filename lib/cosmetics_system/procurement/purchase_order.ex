defmodule CosmeticsSystem.Procurement.PurchaseOrder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "purchase_orders" do
    field :number, :string
    field :status, :string, default: "draft"
    field :total_amount, :decimal
    field :expected_delivery, :date
    field :received_at, :naive_datetime
    field :notes, :string

    belongs_to :supplier, CosmeticsSystem.Procurement.Supplier
    belongs_to :employee, CosmeticsSystem.HR.Employee
    has_many :items, CosmeticsSystem.Procurement.PurchaseOrderItem, on_delete: :delete_all

    timestamps()
  end

  def changeset(po, attrs) do
    po
    |> cast(attrs, [
      :number,
      :status,
      :supplier_id,
      :employee_id,
      :total_amount,
      :expected_delivery,
      :received_at,
      :notes
    ])
    |> validate_required([:supplier_id])
  end
end
