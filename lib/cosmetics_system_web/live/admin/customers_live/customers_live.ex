defmodule CosmeticsSystemWeb.Admin.CustomersLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.CRM
  alias CosmeticsSystem.CRM.Customer
  import CosmeticsSystemWeb.Admin.Helpers

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Customers")
     |> assign(:search, "")
     |> assign(:tier_filter, nil)
     |> load_customers()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:customer, %Customer{})
    |> assign(:changeset, CRM.change_customer(%Customer{}))
    |> assign(:user_options, user_select_options(users_for_customer_form(%Customer{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    customer = CRM.get_customer!(id)

    socket
    |> assign(:customer, customer)
    |> assign(:changeset, CRM.change_customer(customer))
    |> assign(:user_options, user_select_options(users_for_customer_form(customer)))
  end

  @impl true
  def handle_event("search", %{"value" => q}, socket) do
    {:noreply, socket |> assign(:search, q) |> load_customers()}
  end

  @impl true
  def handle_event("filter_tier", %{"tier" => tier}, socket) do
    tier = if tier == "", do: nil, else: tier
    {:noreply, socket |> assign(:tier_filter, tier) |> load_customers()}
  end

  @impl true
  def handle_event("save", %{"customer" => params}, socket) do
    save_customer(socket, socket.assigns.live_action, params)
  end

  defp save_customer(socket, :new, params) do
    case CRM.create_customer(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Customer created.")
         |> push_patch(to: ~p"/admin/customers")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_customer(socket, :edit, params) do
    case CRM.update_customer(socket.assigns.customer, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Customer updated.")
         |> push_patch(to: ~p"/admin/customers")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_customers(socket) do
    customers =
      CRM.list_customers(
        search: socket.assigns.search,
        tier: socket.assigns.tier_filter
      )

    assign(socket, :customers, customers)
  end

  defp tier_filter_active?(filter, "all"), do: filter in [nil, ""]
  defp tier_filter_active?(filter, tier), do: filter == tier
end
