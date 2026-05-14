defmodule CosmeticsSystem.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string
      add :date_of_birth, :date
      add :loyalty_tier, :string, default: "bronze"
      add :loyalty_points, :integer, default: 0
      add :notes, :text
      add :opted_in_marketing, :boolean, default: false

      timestamps()
    end

    create unique_index(:customers, [:user_id])
    create index(:customers, [:loyalty_tier])

    create table(:addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :customer_id, references(:customers, type: :binary_id, on_delete: :delete_all),
        null: false

      add :label, :string, default: "home"
      add :line1, :string, null: false
      add :line2, :string
      add :city, :string, null: false
      add :state, :string
      add :postal_code, :string
      add :country, :string, null: false, default: "KE"
      add :is_default, :boolean, default: false

      timestamps()
    end

    create index(:addresses, [:customer_id])
  end
end
