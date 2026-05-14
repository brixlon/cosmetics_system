defmodule CosmeticsSystemWeb.Shop.HomeLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Beauty & Cosmetics")
     |> assign(:featured, Catalog.list_featured_products(8))
     |> assign(:categories, Catalog.list_root_categories())}
  end

  defp product_card(assigns) do
    ~H"""
    <.link navigate={~p"/shop/products/#{@product.slug}"} class="product-card">
      <%= if img = Enum.find(@product.images, & &1.is_primary) || List.first(@product.images) do %>
        <img src={img.url} alt={@product.name} class="product-card__image" loading="lazy" />
      <% else %>
        <div class="product-card__placeholder"></div>
      <% end %>
      <div class="product-card__body">
        <span class="product-card__category">{@product.category && @product.category.name}</span>
        <h3 class="product-card__name">{@product.name}</h3>
        <span class="product-card__price">KES {@product.base_price}</span>
      </div>
    </.link>
    """
  end
end
