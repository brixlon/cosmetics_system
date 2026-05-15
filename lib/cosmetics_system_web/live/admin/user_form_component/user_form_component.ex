defmodule CosmeticsSystemWeb.Admin.UserFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @roles ~w(customer staff admin)

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))
     |> assign(:role_options, role_options())}
  end

  defp form_title(%{id: nil}), do: "New account"
  defp form_title(_), do: "Edit account"

  defp role_options do
    for role <- @roles, do: {String.capitalize(role), role}
  end
end
