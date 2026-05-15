defmodule CosmeticsSystemWeb.Admin.ProductImageHelpers do
  @moduledoc false

  import Phoenix.LiveView, only: [allow_upload: 3, consume_uploaded_entries: 3, cancel_upload: 3]
  import Phoenix.Component, only: [assign: 3]

  alias CosmeticsSystem.Catalog
  alias CosmeticsSystem.Catalog.ProductImageStore

  def allow_product_image_upload(socket) do
    allow_upload(socket, :product_image,
      accept: ~w(.jpg .jpeg .png .webp .gif),
      max_entries: 1,
      max_file_size: 5_000_000,
      auto_upload: false
    )
  end

  def assign_product_image_form(socket, product) do
    primary = Catalog.primary_image(product)

    socket
    |> assign(:primary_image, primary)
    |> assign(:image_alt, primary && primary.alt_text)
    |> assign(:image_url, primary && primary.url)
  end

  def attach_product_image(socket, product, params) do
    alt_text = blank_to_nil(params["image_alt"]) || product.name
    url_from_form = blank_to_nil(params["image_url"])

    uploaded_urls =
      consume_uploaded_entries(socket, :product_image, fn %{path: path}, entry ->
        case ProductImageStore.persist_uploaded_file(path, entry.client_name) do
          {:ok, url} -> {:ok, url}
          {:error, reason} -> {:error, reason}
        end
      end)

    case uploaded_urls do
      [{:error, reason}] ->
        {:error, reason}

      [{:ok, url}] ->
        Catalog.upsert_primary_image(product, url, alt_text: alt_text)
        :ok

      [] when is_binary(url_from_form) ->
        Catalog.upsert_primary_image(product, url_from_form, alt_text: alt_text)
        :ok

      _ ->
        :ok
    end
  end

  def cancel_product_image_upload(socket) do
    Enum.reduce(socket.assigns.uploads.product_image.entries, socket, fn entry, sock ->
      cancel_upload(sock, :product_image, entry.ref)
    end)
  end

  defp blank_to_nil(value) when value in [nil, ""], do: nil
  defp blank_to_nil(value), do: String.trim(value)
end
