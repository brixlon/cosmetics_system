defmodule CosmeticsSystemWeb.Shop.ProductDetailLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Catalog

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :product_detail

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    product = Catalog.get_product_by_slug!(slug)

    {:ok,
     socket
     |> assign(:page_title, product.name)
     |> assign(:product, product)
     |> assign(:selected_variant, List.first(product.variants))
     |> assign(:quantity, 1)
     |> assign(
       :active_image,
       Enum.find(product.images, & &1.is_primary) || List.first(product.images)
     )}
  end

  @impl true
  def handle_event("select_variant", %{"id" => id}, socket) do
    variant = Enum.find(socket.assigns.product.variants, &(&1.id == id))
    {:noreply, assign(socket, :selected_variant, variant)}
  end

  @impl true
  def handle_event("set_quantity", %{"qty" => qty}, socket) do
    {:noreply, assign(socket, :quantity, max(1, String.to_integer(qty)))}
  end

  @impl true
  def handle_event("add_to_cart", _params, socket) do
    variant = socket.assigns.selected_variant
    qty = socket.assigns.quantity

    if variant && variant.stock_quantity >= qty do
      send(self(), {:add_to_cart, variant.id, qty})
      {:noreply, put_flash(socket, :info, "Added to cart!")}
    else
      {:noreply, put_flash(socket, :error, "Not enough stock available.")}
    end
  end

  @impl true
  def handle_event("select_image", %{"id" => id}, socket) do
    image = Enum.find(socket.assigns.product.images, &(&1.id == id))
    {:noreply, assign(socket, :active_image, image)}
  end

  defp stock_class(v) when v.stock_quantity == 0, do: "danger"
  defp stock_class(v) when v.stock_quantity <= v.low_stock_threshold, do: "warning"
  defp stock_class(_), do: "success"

  defp stock_label(v) when v.stock_quantity == 0, do: "Out of stock"

  defp stock_label(v) when v.stock_quantity <= v.low_stock_threshold,
    do: "Only #{v.stock_quantity} left!"

  defp stock_label(_), do: "In stock"
end
