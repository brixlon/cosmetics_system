defmodule CosmeticsSystem.Repo do
  use Ecto.Repo,
    otp_app: :cosmetics_system,
    adapter: Ecto.Adapters.Postgres
end
