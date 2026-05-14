defmodule CosmeticsSystemWeb.Shop.ProductsLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    products = Catalog.list_products(preload: [:category, :images])

    {:ok,
     socket
     |> assign(:page_title, "Products")
     |> assign(:products, products)}
  end
end
