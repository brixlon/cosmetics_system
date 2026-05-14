defmodule CosmeticsSystem.HR do
  @moduledoc """
  The HR context — employees, departments.
  """
  import Ecto.Query, warn: false
  alias CosmeticsSystem.Repo
  alias CosmeticsSystem.HR.Employee

  def list_employees(opts \\ []) do
    Employee
    |> then(fn q -> if opts[:active_only], do: where(q, [e], e.active == true), else: q end)
    |> then(fn q ->
      if dept = opts[:department], do: where(q, [e], e.department == ^dept), else: q
    end)
    |> order_by([e], asc: e.last_name)
    |> Repo.all()
  end

  def get_employee!(id), do: Repo.get!(Employee, id) |> Repo.preload(:user)

  def create_employee(attrs) do
    %Employee{}
    |> Employee.changeset(attrs)
    |> Repo.insert()
  end

  def update_employee(%Employee{} = employee, attrs) do
    employee
    |> Employee.changeset(attrs)
    |> Repo.update()
  end

  def terminate_employee(%Employee{} = employee) do
    employee
    |> Employee.changeset(%{active: false, terminated_on: Date.utc_today()})
    |> Repo.update()
  end

  def headcount_by_department do
    Employee
    |> where([e], e.active == true)
    |> group_by([e], e.department)
    |> select([e], {e.department, count(e.id)})
    |> Repo.all()
    |> Map.new()
  end

  def payroll_total do
    Employee
    |> where([e], e.active == true)
    |> select([e], sum(e.salary))
    |> Repo.one()
  end

  def staff_on_leave_count, do: 0
end
