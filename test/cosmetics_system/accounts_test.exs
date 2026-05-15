defmodule CosmeticsSystem.AccountsTest do
  use CosmeticsSystem.DataCase

  alias CosmeticsSystem.Accounts
  alias CosmeticsSystem.AccountsFixtures

  describe "register_user/1" do
    test "creates a user with hashed password" do
      {:ok, user} =
        Accounts.register_user(%{
          email: "ada@example.com",
          password: "a valid password",
          role: "customer"
        })

      assert user.email == "ada@example.com"
      assert user.role == "customer"
      assert is_binary(user.hashed_password)
      refute user.hashed_password == "a valid password"
    end

    test "rejects invalid email" do
      assert {:error, changeset} =
               Accounts.register_user(%{email: "not-an-email", password: "a valid password"})

      assert "must have @ sign and no spaces" in errors_on(changeset).email
    end
  end

  describe "users_without_customer_profile/0" do
    test "excludes users that already have a customer profile" do
      user = AccountsFixtures.user_fixture(%{role: "customer"})

      assert user.id in Enum.map(Accounts.users_without_customer_profile(), & &1.id)

      {:ok, _customer} =
        CosmeticsSystem.CRM.create_customer(%{
          first_name: "Ada",
          last_name: "Lovelace",
          user_id: user.id
        })

      refute user.id in Enum.map(Accounts.users_without_customer_profile(), & &1.id)
    end
  end
end
