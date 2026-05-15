defmodule CosmeticsSystemWeb.Admin.OrderDetailLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Orders
  import CosmeticsSystemWeb.Admin.Helpers

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :order_detail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Order")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    order = Orders.get_order!(id)

    {:noreply,
     socket
     |> assign(:order, order)
     |> assign(:page_title, "Order #{order.number}")}
  end

  defp payment_badge("paid"), do: "badge--success"
  defp payment_badge("unpaid"), do: "badge--danger"
  defp payment_badge(_), do: "badge--neutral"
end
