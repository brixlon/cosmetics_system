defmodule CosmeticsSystem.Repo.Migrations.CreateProcurement do
  use Ecto.Migration

  def change do
    create table(:suppliers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :contact_name, :string
      add :email, :string
      add :phone, :string
      add :website, :string
      add :country, :string
      add :address, :text
      add :payment_terms, :string
      add :notes, :text
      add :active, :boolean, default: true

      timestamps()
    end

    create index(:suppliers, [:active])

    # Now that suppliers exist, add FK on products
    alter table(:products) do
      modify :supplier_id, references(:suppliers, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:products, [:supplier_id])

    create table(:purchase_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :supplier_id, references(:suppliers, type: :binary_id, on_delete: :restrict), null: false
      add :employee_id, references(:employees, type: :binary_id, on_delete: :nilify_all)
      add :number, :string, null: false
      add :status, :string, null: false, default: "draft"
      add :total_amount, :decimal, precision: 10, scale: 2
      add :expected_delivery, :date
      add :received_at, :naive_datetime
      add :notes, :text

      timestamps()
    end

    create unique_index(:purchase_orders, [:number])
    create index(:purchase_orders, [:supplier_id])
    create index(:purchase_orders, [:status])

    create table(:purchase_order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :purchase_order_id, references(:purchase_orders, type: :binary_id, on_delete: :delete_all), null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :restrict), null: false
      add :variant_id, references(:product_variants, type: :binary_id, on_delete: :restrict)
      add :quantity, :integer, null: false
      add :unit_cost, :decimal, precision: 10, scale: 2, null: false
      add :received_quantity, :integer, default: 0

      timestamps()
    end

    create index(:purchase_order_items, [:purchase_order_id])
  end
end
