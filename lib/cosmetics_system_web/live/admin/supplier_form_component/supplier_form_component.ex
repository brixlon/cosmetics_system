defmodule CosmeticsSystemWeb.Admin.SupplierFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))}
  end

  defp form_title(%{id: nil}), do: "New supplier"
  defp form_title(_), do: "Edit supplier"
end
