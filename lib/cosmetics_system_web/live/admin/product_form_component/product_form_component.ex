defmodule CosmeticsSystemWeb.Admin.ProductFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @impl true
  def render(assigns), do: product_form_component(assigns)

  @impl true
  def update(%{id: id, product: product, changeset: changeset, categories: categories}, socket) do
    {:ok,
     socket
     |> assign(:id, id)
     |> assign(:product, product)
     |> assign(:changeset, changeset)
     |> assign(:categories, categories)
     |> assign(:form, to_form(changeset))
     |> assign(:category_options, Enum.map(categories, &{&1.name, &1.id}))}
  end

  defp form_title(%{id: nil}), do: "New product"
  defp form_title(_), do: "Edit product"
end
