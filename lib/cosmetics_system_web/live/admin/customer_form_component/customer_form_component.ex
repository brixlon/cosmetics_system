defmodule CosmeticsSystemWeb.Admin.CustomerFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))
     |> assign(:tier_options, tier_options())
     |> assign(:user_options, user_options(assigns.user_options))}
  end

  defp form_title(%{id: nil}), do: "New customer"
  defp form_title(_), do: "Edit customer"

  defp tier_options do
    for tier <- ~w(bronze silver gold platinum), do: {String.capitalize(tier), tier}
  end

  defp user_options(options), do: [{"Select account", ""} | options]
end
