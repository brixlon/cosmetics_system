defmodule CosmeticsSystemWeb.Shop.OrderStatusLive do
  use CosmeticsSystemWeb, :live_view

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :order_status

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Order status")}
  end

  @impl true
  def handle_params(%{"number" => number}, _uri, socket) do
    {:noreply, assign(socket, :order_number, number)}
  end
end
