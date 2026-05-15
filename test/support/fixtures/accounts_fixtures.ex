defmodule CosmeticsSystem.AccountsFixtures do
  @moduledoc false

  alias CosmeticsSystem.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        password: valid_user_password(),
        role: "customer"
      })
      |> Accounts.register_user()

    user
  end
end
