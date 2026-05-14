defmodule CosmeticsSystemWeb.Admin.OrdersLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Orders

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(CosmeticsSystem.PubSub, "orders")

    {:ok,
     socket
     |> assign(:page_title, "Orders")
     |> assign(:status_filter, nil)
     |> load_orders()}
  end

  @impl true
  def handle_info({:order_updated, _order}, socket) do
    {:noreply, load_orders(socket)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    status = if status == "", do: nil, else: status
    {:noreply, socket |> assign(:status_filter, status) |> load_orders()}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    order = Orders.get_order!(id)
    {:ok, _} = Orders.update_order_status(order, status)
    {:noreply, load_orders(socket)}
  end

  defp load_orders(socket) do
    assign(socket, :orders, Orders.list_orders(status: socket.assigns.status_filter))
  end

  defp order_filter_active?(sf, "all"), do: sf in [nil, ""]

  defp order_filter_active?(sf, status), do: sf == status

  defp payment_badge("paid"), do: "success"
  defp payment_badge("unpaid"), do: "danger"
  defp payment_badge(_), do: "neutral"
end
