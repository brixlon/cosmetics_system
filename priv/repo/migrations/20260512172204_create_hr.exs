defmodule CosmeticsSystem.Repo.Migrations.CreateHR do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :employee_number, :string, null: false
      add :department, :string, null: false
      add :position, :string, null: false
      add :salary, :decimal, precision: 10, scale: 2
      add :hired_on, :date, null: false
      add :terminated_on, :date
      add :phone, :string
      add :national_id, :string
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:employees, [:employee_number])
    create unique_index(:employees, [:user_id])
    create index(:employees, [:department])
    create index(:employees, [:active])
  end
end
