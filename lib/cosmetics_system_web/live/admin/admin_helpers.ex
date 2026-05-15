defmodule CosmeticsSystemWeb.Admin.Helpers do
  @moduledoc false

  alias CosmeticsSystem.Accounts
  alias CosmeticsSystem.Accounts.User

  def user_select_options(users) do
    Enum.map(users, &{&1.email, &1.id})
  end

  def users_for_customer_form(%{id: id} = customer) when not is_nil(id) do
    available = Accounts.users_without_customer_profile()

    case customer.user do
      %User{} = user -> Enum.uniq_by([user | available], & &1.id)
      _ -> available
    end
  end

  def users_for_customer_form(_), do: Accounts.users_without_customer_profile()

  def users_for_employee_form(%{id: id} = employee) when not is_nil(id) do
    available = Accounts.users_without_employee_profile()

    case employee.user do
      %User{} = user -> Enum.uniq_by([user | available], & &1.id)
      _ -> available
    end
  end

  def users_for_employee_form(_), do: Accounts.users_without_employee_profile()

  def supplier_select_options(suppliers) do
    Enum.map(suppliers, &{&1.name, &1.id})
  end

  def employee_select_options(employees) do
    Enum.map(employees, fn e ->
      {"#{e.first_name} #{e.last_name}", e.id}
    end)
  end

  def loyalty_badge("platinum"), do: "badge--success"
  def loyalty_badge("gold"), do: "badge--success"
  def loyalty_badge("silver"), do: "badge--neutral"
  def loyalty_badge(_), do: "badge--neutral"

  def format_date(nil), do: "—"
  def format_date(%Date{} = date), do: Calendar.strftime(date, "%d %b %Y")

  def format_datetime(nil), do: "—"

  def format_datetime(%NaiveDateTime{} = dt),
    do: Calendar.strftime(dt, "%d %b %Y %H:%M")

  def format_datetime(%DateTime{} = dt),
    do: dt |> DateTime.to_naive() |> format_datetime()
end
