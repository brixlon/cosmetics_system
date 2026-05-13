defmodule CosmeticsSystem.Slug do
  @moduledoc false

  def slugify(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
  end

  def slugify(_), do: ""
end
