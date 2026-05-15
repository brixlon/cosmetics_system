defmodule CosmeticsSystemWeb.Admin.PurchaseOrderFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @statuses ~w(draft ordered in_transit received cancelled)

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))
     |> assign(:status_options, status_options())
     |> assign(:supplier_options, select_options(assigns.supplier_options, "Select supplier"))
     |> assign(:employee_options, select_options(assigns.employee_options, "Unassigned"))}
  end

  defp form_title(%{id: nil}), do: "New purchase order"
  defp form_title(_), do: "Edit purchase order"

  defp status_options do
    for status <- @statuses, do: {String.capitalize(String.replace(status, "_", " ")), status}
  end

  defp select_options(options, prompt), do: [{prompt, ""} | options]
end
