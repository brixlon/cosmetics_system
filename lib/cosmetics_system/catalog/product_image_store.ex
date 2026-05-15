defmodule CosmeticsSystem.Catalog.ProductImageStore do
  @moduledoc false

  @upload_subdir "products"
  @allowed_ext ~w(.jpg .jpeg .png .webp .gif)

  def uploads_dir do
    Path.join([:code.priv_dir(:cosmetics_system), "static", "uploads", @upload_subdir])
  end

  def persist_uploaded_file(path, client_name) do
    ext = client_name |> Path.extname() |> String.downcase()

    if ext in @allowed_ext do
      filename = "#{Ecto.UUID.generate()}#{ext}"
      dest_dir = uploads_dir()
      File.mkdir_p!(dest_dir)
      dest = Path.join(dest_dir, filename)
      File.cp!(path, dest)
      {:ok, public_url(filename)}
    else
      {:error, :invalid_extension}
    end
  end

  def public_url(filename), do: "/uploads/#{@upload_subdir}/#{filename}"
end
