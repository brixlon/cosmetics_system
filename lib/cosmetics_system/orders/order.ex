defmodule CosmeticsSystem.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending processing shipped delivered cancelled refunded)
  @payment_statuses ~w(unpaid paid partially_refunded refunded)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "orders" do
    field :number, :string
    field :status, :string, default: "pending"
    field :subtotal, :decimal
    field :discount_amount, :decimal, default: 0
    field :tax_amount, :decimal, default: 0
    field :shipping_fee, :decimal, default: 0
    field :total, :decimal
    field :payment_status, :string, default: "unpaid"
    field :notes, :string
    field :shipped_at, :naive_datetime
    field :delivered_at, :naive_datetime

    belongs_to :customer, CosmeticsSystem.CRM.Customer
    belongs_to :shipping_address, CosmeticsSystem.CRM.Address
    has_many :items, CosmeticsSystem.Orders.OrderItem, on_delete: :delete_all
    has_many :payments, CosmeticsSystem.Orders.Payment

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :status,
      :subtotal,
      :discount_amount,
      :tax_amount,
      :shipping_fee,
      :total,
      :payment_status,
      :notes,
      :shipped_at,
      :delivered_at,
      :customer_id,
      :shipping_address_id
    ])
    |> validate_required([:customer_id, :subtotal, :total])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:payment_status, @payment_statuses)
    |> maybe_generate_number()
  end

  def calculate_total(order) do
    total =
      Decimal.add(order.subtotal, order.tax_amount)
      |> Decimal.add(order.shipping_fee)
      |> Decimal.sub(order.discount_amount)

    change(order, total: total)
  end

  defp maybe_generate_number(changeset) do
    if is_nil(get_field(changeset, :number)) do
      put_change(changeset, :number, generate_order_number())
    else
      changeset
    end
  end

  defp generate_order_number do
    prefix = "CS"
    timestamp = :os.system_time(:millisecond) |> Integer.to_string(36) |> String.upcase()
    "#{prefix}-#{timestamp}"
  end
end
