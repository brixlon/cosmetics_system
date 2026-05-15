defmodule CosmeticsSystem.Catalog do
  @moduledoc """
  The Catalog context — manages products, variants, categories, images.
  """

  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.Catalog.{Product, ProductVariant, ProductImage, Category}

  # ── Categories ──────────────────────────────────────────────────────

  def list_categories(opts \\ []) do
    Category
    |> where([c], c.active == true)
    |> order_by([c], asc: c.position, asc: c.name)
    |> maybe_preload(opts[:preload])
    |> Repo.all()
  end

  def list_root_categories do
    Category
    |> where([c], is_nil(c.parent_id) and c.active == true)
    |> preload(:subcategories)
    |> Repo.all()
  end

  def get_category!(id), do: Repo.get!(Category, id)
  def get_category_by_slug!(slug), do: Repo.get_by!(Category, slug: slug)

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category), do: Repo.delete(category)

  # ── Products ────────────────────────────────────────────────────────

  def list_products(opts \\ []) do
    Product
    |> apply_product_filters(opts)
    |> order_by([p], desc: p.inserted_at)
    |> maybe_preload(opts[:preload])
    |> Repo.all()
  end

  def list_featured_products(limit \\ 8) do
    Product
    |> where([p], p.featured == true and p.active == true)
    |> preload([:category, :images, :variants])
    |> limit(^limit)
    |> Repo.all()
  end

  def search_products(query_string) do
    term = "%#{query_string}%"

    Product
    |> where([p], ilike(p.name, ^term) or ilike(p.description, ^term) or ilike(p.sku, ^term))
    |> where([p], p.active == true)
    |> preload([:category, :images])
    |> Repo.all()
  end

  def get_product!(id),
    do: Repo.get!(Product, id) |> Repo.preload([:category, :variants, :images, :supplier])

  def get_product_by_slug!(slug),
    do: Repo.get_by!(Product, slug: slug) |> Repo.preload([:category, :variants, :images])

  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def delete_product(%Product{} = product), do: Repo.delete(product)

  def change_product(%Product{} = product, attrs \\ %{}), do: Product.changeset(product, attrs)

  # ── Variants ────────────────────────────────────────────────────────

  def get_variant!(id), do: Repo.get!(ProductVariant, id)

  def create_variant(attrs) do
    %ProductVariant{}
    |> ProductVariant.changeset(attrs)
    |> Repo.insert()
  end

  def update_variant(%ProductVariant{} = variant, attrs) do
    variant
    |> ProductVariant.changeset(attrs)
    |> Repo.update()
  end

  def adjust_stock(%ProductVariant{} = variant, quantity_delta) do
    new_qty = max(0, variant.stock_quantity + quantity_delta)

    variant
    |> Ecto.Changeset.change(stock_quantity: new_qty)
    |> Repo.update()
    |> tap(fn
      {:ok, v} when v.stock_quantity <= v.low_stock_threshold ->
        CosmeticsSystem.Notifications.low_stock_alert(v)

      _ ->
        :ok
    end)
  end

  def adjust_stock_by_product(product_id, variant_id, quantity_delta) do
    case Repo.get_by(ProductVariant, id: variant_id, product_id: product_id) do
      %ProductVariant{} = variant -> adjust_stock(variant, quantity_delta)
      nil -> {:error, :not_found}
    end
  end

  def low_stock_products do
    from(v in ProductVariant,
      join: p in assoc(v, :product),
      where: v.stock_quantity <= v.low_stock_threshold and v.active == true,
      preload: [product: p]
    )
    |> Repo.all()
  end

  # ── Images ──────────────────────────────────────────────────────────

  def add_product_image(product_id, url, opts \\ []) do
    %ProductImage{}
    |> Ecto.Changeset.cast(
      %{
        product_id: product_id,
        url: url,
        alt_text: opts[:alt_text],
        position: opts[:position] || 0,
        is_primary: opts[:is_primary] || false
      },
      [:product_id, :url, :alt_text, :position, :is_primary]
    )
    |> Repo.insert()
  end

  def set_primary_image(image_id, product_id) do
    Repo.transaction(fn ->
      from(i in ProductImage, where: i.product_id == ^product_id)
      |> Repo.update_all(set: [is_primary: false])

      from(i in ProductImage, where: i.id == ^image_id)
      |> Repo.update_all(set: [is_primary: true])
    end)
  end

  def primary_image(%Product{images: images}) when is_list(images) do
    Enum.find(images, & &1.is_primary) || List.first(images)
  end

  def primary_image(_), do: nil

  def upsert_primary_image(%Product{} = product, url, opts \\ []) when is_binary(url) do
    alt_text = opts[:alt_text] || product.name

    case primary_image(product) do
      %ProductImage{} = image ->
        image
        |> ProductImage.changeset(%{url: url, alt_text: alt_text})
        |> Repo.update()

      nil ->
        add_product_image(product.id, url,
          alt_text: alt_text,
          is_primary: true,
          position: 0
        )
    end
  end

  def delete_product_image(%ProductImage{} = image), do: Repo.delete(image)

  # ── Private helpers ─────────────────────────────────────────────────

  defp apply_product_filters(query, opts) do
    query
    |> then(fn q ->
      if opts[:active_only] != false, do: where(q, [p], p.active == true), else: q
    end)
    |> then(fn q ->
      if cat = opts[:category_id], do: where(q, [p], p.category_id == ^cat), else: q
    end)
    |> then(fn q ->
      if supplier = opts[:supplier_id], do: where(q, [p], p.supplier_id == ^supplier), else: q
    end)
    |> then(fn q ->
      case opts[:price_range] do
        {min, max} -> where(q, [p], p.base_price >= ^min and p.base_price <= ^max)
        _ -> q
      end
    end)
  end

  defp maybe_preload(query, nil), do: query
  defp maybe_preload(query, preloads), do: preload(query, ^preloads)
end
