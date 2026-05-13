defmodule CosmeticsSystem.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :role, :string, null: false, default: "customer"
      add :confirmed_at, :naive_datetime

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:role])
  end
end
