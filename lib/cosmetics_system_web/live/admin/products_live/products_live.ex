defmodule CosmeticsSystemWeb.Admin.ProductsLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog
  alias CosmeticsSystem.Catalog.Product

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Products")
     |> assign(:search, "")
     |> assign(:category_filter, nil)
     |> load_products()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:product, %Product{})
    |> assign(:changeset, Catalog.change_product(%Product{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    product = Catalog.get_product!(id)

    socket
    |> assign(:product, product)
    |> assign(:changeset, Catalog.change_product(product))
  end

  @impl true
  def handle_event("search", %{"value" => q}, socket) do
    {:noreply, socket |> assign(:search, q) |> load_products()}
  end

  @impl true
  def handle_event("filter_category", %{"id" => id}, socket) do
    {:noreply, socket |> assign(:category_filter, id) |> load_products()}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    product = Catalog.get_product!(id)
    {:ok, _} = Catalog.update_product(product, %{active: !product.active})
    {:noreply, load_products(socket)}
  end

  @impl true
  def handle_event("save", %{"product" => params}, socket) do
    save_product(socket, socket.assigns.live_action, params)
  end

  defp save_product(socket, :new, params) do
    case Catalog.create_product(params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully.")
         |> push_navigate(to: ~p"/admin/products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :edit, params) do
    case Catalog.update_product(socket.assigns.product, params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully.")
         |> push_navigate(to: ~p"/admin/products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_products(socket) do
    products =
      if socket.assigns.search != "" do
        Catalog.search_products(socket.assigns.search)
      else
        Catalog.list_products(
          preload: [:category, :images, :variants],
          category_id: socket.assigns.category_filter
        )
      end

    assign(socket, :products, products)
  end
end
