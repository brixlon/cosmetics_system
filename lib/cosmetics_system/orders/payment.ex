defmodule CosmeticsSystem.Orders.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payments" do
    field :amount, :decimal
    field :method, :string
    field :status, :string, default: "pending"

    belongs_to :order, CosmeticsSystem.Orders.Order

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :method, :status, :order_id])
    |> validate_required([:amount, :order_id])
  end
end
