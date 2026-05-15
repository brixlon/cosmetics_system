defmodule CosmeticsSystemWeb.Admin.ProductsLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog
  alias CosmeticsSystem.Catalog.Product

  import CosmeticsSystemWeb.Admin.ProductImageHelpers

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
     |> allow_product_image_upload()
     |> load_products()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> cancel_product_image_upload()
    |> assign(:primary_image, nil)
  end

  defp apply_action(socket, :new, _params) do
    product = %Product{}

    socket
    |> cancel_product_image_upload()
    |> assign(:product, product)
    |> assign(:changeset, Catalog.change_product(product))
    |> assign_product_image_form(product)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    product = Catalog.get_product!(id)

    socket
    |> cancel_product_image_upload()
    |> assign(:product, product)
    |> assign(:changeset, Catalog.change_product(product))
    |> assign_product_image_form(product)
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
  def handle_event("validate", %{"product" => params} = all_params, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params(params))
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:image_url, all_params["image_url"])
     |> assign(:image_alt, all_params["image_alt"])}
  end

  @impl true
  def handle_event("save", params, socket) do
    save_product(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :product_image, ref)}
  end

  defp save_product(socket, :new, params) do
    case Catalog.create_product(product_params(params["product"])) do
      {:ok, product} ->
        case attach_product_image(socket, product, params) do
          :ok ->
            {:noreply,
             socket
             |> put_flash(:info, "Product created successfully.")
             |> push_patch(to: ~p"/admin/products")}

          {:error, :invalid_extension} ->
            {:noreply,
             socket
             |> put_flash(:error, "Image must be JPG, PNG, WebP, or GIF.")
             |> assign(:changeset, Catalog.change_product(product))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :edit, params) do
    case Catalog.update_product(socket.assigns.product, product_params(params["product"])) do
      {:ok, product} ->
        product = Catalog.get_product!(product.id)

        case attach_product_image(socket, product, params) do
          :ok ->
            {:noreply,
             socket
             |> put_flash(:info, "Product updated successfully.")
             |> push_patch(to: ~p"/admin/products")}

          {:error, :invalid_extension} ->
            {:noreply,
             socket
             |> put_flash(:error, "Image must be JPG, PNG, WebP, or GIF.")
             |> assign(:changeset, Catalog.change_product(product))}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp product_params(params) when is_map(params) do
    Map.drop(params, ["image_url", "image_alt"])
  end

  defp load_products(socket) do
    products =
      if socket.assigns.search != "" do
        Catalog.search_products(socket.assigns.search)
      else
        Catalog.list_products(
          preload: [:category, :images, :variants],
          category_id: socket.assigns.category_filter,
          active_only: false
        )
      end

    assign(socket, :products, products)
  end
end
