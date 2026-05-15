defmodule CosmeticsSystemWeb.Admin.ProductFormComponent do
  use CosmeticsSystemWeb, :live_component

  embed_templates("*")

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(assigns.changeset))
     |> assign(:category_options, Enum.map(assigns.categories, &{&1.name, &1.id}))}
  end

  defp form_title(%{id: nil}), do: "New product"
  defp form_title(_), do: "Edit product"

  defp current_image_url(assigns) do
    assigns[:image_url] || (assigns.primary_image && assigns.primary_image.url)
  end

  defp current_image_alt(assigns) do
    assigns[:image_alt] || (assigns.primary_image && assigns.primary_image.alt_text) ||
      assigns.product.name
  end

  defp product_upload_error_to_string(:too_large), do: "File is too large (max 5 MB)"
  defp product_upload_error_to_string(:not_accepted), do: "File type must be JPG, PNG, WebP, or GIF"
  defp product_upload_error_to_string(:too_many_files), do: "Only one image allowed"
  defp product_upload_error_to_string(err), do: "Upload error: #{inspect(err)}"
end
