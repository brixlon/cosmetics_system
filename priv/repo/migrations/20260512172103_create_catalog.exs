defmodule CosmeticsSystem.Repo.Migrations.CreateCatalog do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :parent_id, references(:categories, type: :binary_id, on_delete: :nilify_all)
      add :position, :integer, default: 0
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:categories, [:slug])

    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :category_id, references(:categories, type: :binary_id, on_delete: :nilify_all)
      # references suppliers (added after)
      add :supplier_id, :binary_id
      add :name, :string, null: false
      add :slug, :string, null: false
      add :sku, :string, null: false
      add :description, :text
      add :ingredients, :text
      add :how_to_use, :text
      add :base_price, :decimal, precision: 10, scale: 2, null: false
      add :compare_at_price, :decimal, precision: 10, scale: 2
      add :cost_price, :decimal, precision: 10, scale: 2
      add :active, :boolean, default: true
      add :featured, :boolean, default: false
      add :tags, {:array, :string}, default: []

      timestamps()
    end

    create unique_index(:products, [:slug])
    create unique_index(:products, [:sku])
    create index(:products, [:category_id])
    create index(:products, [:active])

    create table(:product_variants, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      add :name, :string, null: false
      add :sku, :string, null: false
      add :shade, :string
      add :size, :string
      add :fragrance, :string
      add :price_modifier, :decimal, precision: 10, scale: 2, default: 0
      add :stock_quantity, :integer, default: 0
      add :low_stock_threshold, :integer, default: 10
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:product_variants, [:sku])
    create index(:product_variants, [:product_id])

    create table(:product_images, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all),
        null: false

      add :url, :string, null: false
      add :alt_text, :string
      add :position, :integer, default: 0
      add :is_primary, :boolean, default: false

      timestamps()
    end

    create index(:product_images, [:product_id])
  end
end
