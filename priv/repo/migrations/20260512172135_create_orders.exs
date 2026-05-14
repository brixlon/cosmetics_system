defmodule CosmeticsSystem.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :customer_id, references(:customers, type: :binary_id, on_delete: :restrict),
        null: false

      add :shipping_address_id, references(:addresses, type: :binary_id, on_delete: :nilify_all)
      add :number, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :subtotal, :decimal, precision: 10, scale: 2, null: false
      add :discount_amount, :decimal, precision: 10, scale: 2, default: 0
      add :tax_amount, :decimal, precision: 10, scale: 2, default: 0
      add :shipping_fee, :decimal, precision: 10, scale: 2, default: 0
      add :total, :decimal, precision: 10, scale: 2, null: false
      add :payment_status, :string, default: "unpaid"
      add :notes, :text
      add :shipped_at, :naive_datetime
      add :delivered_at, :naive_datetime

      timestamps()
    end

    create unique_index(:orders, [:number])
    create index(:orders, [:customer_id])
    create index(:orders, [:status])
    create index(:orders, [:payment_status])

    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order_id, references(:orders, type: :binary_id, on_delete: :delete_all), null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :restrict), null: false
      add :variant_id, references(:product_variants, type: :binary_id, on_delete: :restrict)
      add :product_name, :string, null: false
      add :variant_name, :string
      add :quantity, :integer, null: false
      add :unit_price, :decimal, precision: 10, scale: 2, null: false
      add :line_total, :decimal, precision: 10, scale: 2, null: false

      timestamps()
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])

    create table(:payments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :order_id, references(:orders, type: :binary_id, on_delete: :restrict), null: false
      add :provider, :string, null: false
      add :provider_ref, :string
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :string, default: "KES"
      add :status, :string, null: false, default: "pending"
      add :metadata, :map

      timestamps()
    end

    create index(:payments, [:order_id])
    create index(:payments, [:provider_ref])
  end
end
