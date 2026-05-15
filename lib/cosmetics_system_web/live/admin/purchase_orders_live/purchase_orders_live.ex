defmodule CosmeticsSystemWeb.Admin.PurchaseOrdersLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.HR
  alias CosmeticsSystem.Procurement
  alias CosmeticsSystem.Procurement.PurchaseOrder
  import CosmeticsSystemWeb.Admin.Helpers

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Purchase orders")
     |> assign(:status_filter, nil)
     |> load_purchase_orders()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:purchase_order, %PurchaseOrder{})
    |> assign(:changeset, Procurement.change_purchase_order(%PurchaseOrder{}))
    |> assign_form_options()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    po = Procurement.get_purchase_order!(id)

    socket
    |> assign(:purchase_order, po)
    |> assign(:changeset, Procurement.change_purchase_order(po))
    |> assign_form_options()
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    status = if status == "", do: nil, else: status
    {:noreply, socket |> assign(:status_filter, status) |> load_purchase_orders()}
  end

  @impl true
  def handle_event("save", %{"purchase_order" => params}, socket) do
    save_purchase_order(socket, socket.assigns.live_action, params)
  end

  defp save_purchase_order(socket, :new, params) do
    case Procurement.create_purchase_order_header(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Purchase order created.")
         |> push_patch(to: ~p"/admin/purchase-orders")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_purchase_order(socket, :edit, params) do
    case Procurement.update_purchase_order(socket.assigns.purchase_order, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Purchase order updated.")
         |> push_patch(to: ~p"/admin/purchase-orders")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_purchase_orders(socket) do
    pos = Procurement.list_purchase_orders(status: socket.assigns.status_filter)
    assign(socket, :purchase_orders, pos)
  end

  defp assign_form_options(socket) do
    socket
    |> assign(:supplier_options, supplier_select_options(Procurement.list_suppliers(active_only: true)))
    |> assign(:employee_options, employee_select_options(HR.list_employees(active_only: true)))
  end

  defp status_filter_active?(filter, "all"), do: filter in [nil, ""]
  defp status_filter_active?(filter, status), do: filter == status
end
