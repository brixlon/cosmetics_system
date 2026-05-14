defmodule CosmeticsSystem.Orders.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payments" do
    field :provider, :string
    field :provider_ref, :string
    field :amount, :decimal
    field :currency, :string, default: "KES"
    field :status, :string, default: "pending"
    field :metadata, :map

    belongs_to :order, CosmeticsSystem.Orders.Order

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:provider, :provider_ref, :amount, :currency, :status, :metadata, :order_id])
    |> validate_required([:amount, :order_id, :provider])
  end
end
