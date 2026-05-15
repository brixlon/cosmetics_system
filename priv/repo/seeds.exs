# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CosmeticsSystem.Repo.insert!(%CosmeticsSystem.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


# ---------------------------------------------------------------------------
# User accounts (for linking customers & employees in admin)
# ---------------------------------------------------------------------------

import Ecto.Query

alias CosmeticsSystem.Repo
alias CosmeticsSystem.Accounts
alias CosmeticsSystem.Accounts.User
alias CosmeticsSystem.CRM
alias CosmeticsSystem.HR

dev_password = "luminae1234"

upsert_user = fn attrs ->
  email = String.downcase(attrs.email)

  case Repo.get_by(User, email: email) do
    nil ->
      {:ok, user} =
        Accounts.register_user(%{
          email: email,
          password: dev_password,
          role: attrs.role
        })

      user

    user ->
      user
  end
end

_admin = upsert_user.(%{email: "admin@luminae.local", role: "admin"})
staff = upsert_user.(%{email: "staff@luminae.local", role: "staff"})

customer_users =
  for n <- 1..5 do
    upsert_user.(%{email: "customer#{n}@luminae.local", role: "customer"})
  end

# Link sample employee to staff account (idempotent)
unless Repo.exists?(from e in HR.Employee, where: e.user_id == ^staff.id) do
  {:ok, _} =
    HR.create_employee(%{
      first_name: "Sam",
      last_name: "Omondi",
      department: "management",
      position: "Store manager",
      hired_on: ~D[2024-01-15],
      phone: "+254700000001",
      active: true,
      user_id: staff.id
    })
end

# Link sample customers (leave 2 accounts unlinked for admin "new customer" demos)
for {user, {first, last, phone}} <-
      Enum.zip(customer_users, [
        {"Amina", "Wanjiku", "+254712000001"},
        {"Brian", "Ochieng", "+254712000002"},
        {"Chloe", "Muthoni", "+254712000003"}
      ]) do
  unless Repo.exists?(from c in CRM.Customer, where: c.user_id == ^user.id) do
    {:ok, _} =
      CRM.create_customer(%{
        first_name: first,
        last_name: last,
        phone: phone,
        loyalty_tier: "bronze",
        user_id: user.id
      })
  end
end

IO.puts("\n✅  Accounts seeded successfully!")
IO.puts("   Admin:    admin@luminae.local")
IO.puts("   Staff:    staff@luminae.local")
IO.puts("   Customers: customer1@luminae.local … customer5@luminae.local")
IO.puts("   Password (all dev accounts): #{dev_password}")
IO.puts("   Unlinked for demos: customer4@, customer5@ (and admin has no employee duplicate)")
