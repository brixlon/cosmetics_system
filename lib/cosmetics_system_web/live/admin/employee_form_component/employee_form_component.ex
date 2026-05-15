defmodule CosmeticsSystemWeb.Admin.EmployeeFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))
     |> assign(:department_options, department_options())
     |> assign(:user_options, user_options(assigns.user_options))}
  end

  defp form_title(%{id: nil}), do: "New employee"
  defp form_title(_), do: "Edit employee"

  defp department_options do
    for dept <- ~w(management sales warehouse marketing finance),
      do: {String.capitalize(dept), dept}
  end

  defp user_options(options), do: [{"Select account", ""} | options]
end
