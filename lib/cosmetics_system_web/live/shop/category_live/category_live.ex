defmodule CosmeticsSystemWeb.Shop.CategoryLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :category

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :category, nil)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    category = Catalog.get_category_by_slug!(slug)

    {:noreply,
     socket
     |> assign(:page_title, category.name)
     |> assign(:category, category)}
  end
end
