defmodule CosmeticsSystem.Accounts do
  @moduledoc """
  User accounts for shop sign-in and linking customers and employees.
  """
  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.Accounts.User
  alias CosmeticsSystem.CRM.Customer
  alias CosmeticsSystem.HR.Employee

  @staff_roles ~w(admin staff)

  def list_users(opts \\ []) do
    User
    |> then(fn q -> if role = opts[:role], do: where(q, [u], u.role == ^role), else: q end)
    |> order_by([u], asc: u.email)
    |> preload([:customer, :employee])
    |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) when is_binary(email),
    do: Repo.get_by(User, email: String.downcase(email))

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_registration(%User{} = user, attrs \\ %{}),
    do: User.registration_changeset(user, attrs)

  def update_user_registration(%User{} = user, attrs) do
    user
    |> User.registration_changeset(attrs, hash_password: password_change?(attrs))
    |> Repo.update()
  end

  def delete_user(%User{} = user), do: Repo.delete(user)

  def users_without_customer_profile do
    from(u in User,
      left_join: c in Customer,
      on: c.user_id == u.id,
      where: is_nil(c.id) and u.role == "customer",
      order_by: [asc: u.email],
      select: u
    )
    |> Repo.all()
  end

  def users_without_employee_profile do
    from(u in User,
      left_join: e in Employee,
      on: e.user_id == u.id,
      where: is_nil(e.id) and u.role in ^@staff_roles,
      order_by: [asc: u.email],
      select: u
    )
    |> Repo.all()
  end

  defp password_change?(attrs) do
    password = attrs["password"] || attrs[:password]
    is_binary(password) and String.trim(password) != ""
  end
end
