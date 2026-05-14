defmodule CosmeticsSystemWeb.Admin.OrderDetailLive do
  use CosmeticsSystemWeb, :live_view

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :order_detail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Order")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, assign(socket, :order_id, id)}
  end
end
