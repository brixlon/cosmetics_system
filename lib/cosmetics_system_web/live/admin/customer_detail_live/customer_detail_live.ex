defmodule CosmeticsSystemWeb.Admin.CustomerDetailLive do
  use CosmeticsSystemWeb, :live_view

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :customer_detail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Customer")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    {:noreply, assign(socket, :customer_id, id)}
  end
end
