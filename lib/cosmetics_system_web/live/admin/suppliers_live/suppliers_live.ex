defmodule CosmeticsSystemWeb.Admin.SuppliersLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Procurement
  alias CosmeticsSystem.Procurement.Supplier

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Suppliers")
     |> assign(:active_only, false)
     |> load_suppliers()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:supplier, %Supplier{})
    |> assign(:changeset, Procurement.change_supplier(%Supplier{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    supplier = Procurement.get_supplier!(id)

    socket
    |> assign(:supplier, supplier)
    |> assign(:changeset, Procurement.change_supplier(supplier))
  end

  @impl true
  def handle_event("toggle_active_filter", _params, socket) do
    {:noreply, socket |> assign(:active_only, !socket.assigns.active_only) |> load_suppliers()}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    supplier = Procurement.get_supplier!(id)
    {:ok, _} = Procurement.update_supplier(supplier, %{active: !supplier.active})
    {:noreply, load_suppliers(socket)}
  end

  @impl true
  def handle_event("save", %{"supplier" => params}, socket) do
    save_supplier(socket, socket.assigns.live_action, params)
  end

  defp save_supplier(socket, :new, params) do
    case Procurement.create_supplier(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Supplier created.")
         |> push_patch(to: ~p"/admin/suppliers")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_supplier(socket, :edit, params) do
    case Procurement.update_supplier(socket.assigns.supplier, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Supplier updated.")
         |> push_patch(to: ~p"/admin/suppliers")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_suppliers(socket) do
    suppliers =
      Procurement.list_suppliers(active_only: socket.assigns.active_only)

    assign(socket, :suppliers, suppliers)
  end
end
