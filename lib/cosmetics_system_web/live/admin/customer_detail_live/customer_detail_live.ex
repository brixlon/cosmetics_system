defmodule CosmeticsSystemWeb.Admin.CustomerDetailLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.CRM
  alias CosmeticsSystem.CRM.Customer
  import CosmeticsSystemWeb.Admin.Helpers

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :customer_detail

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Customer")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    customer = CRM.get_customer_with_orders!(id)

    {:noreply,
     socket
     |> assign(:customer, customer)
     |> assign(:page_title, Customer.full_name(customer))}
  end
end
