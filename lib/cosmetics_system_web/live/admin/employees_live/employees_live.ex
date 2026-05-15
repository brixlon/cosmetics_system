defmodule CosmeticsSystemWeb.Admin.EmployeesLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.HR
  alias CosmeticsSystem.HR.Employee
  import CosmeticsSystemWeb.Admin.Helpers

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Employees")
     |> assign(:department_filter, nil)
     |> load_employees()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:employee, %Employee{})
    |> assign(:changeset, HR.change_employee(%Employee{}))
    |> assign(:user_options, user_select_options(users_for_employee_form(%Employee{})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    employee = HR.get_employee!(id)

    socket
    |> assign(:employee, employee)
    |> assign(:changeset, HR.change_employee(employee))
    |> assign(:user_options, user_select_options(users_for_employee_form(employee)))
  end

  @impl true
  def handle_event("filter_department", %{"department" => dept}, socket) do
    dept = if dept == "", do: nil, else: dept
    {:noreply, socket |> assign(:department_filter, dept) |> load_employees()}
  end

  @impl true
  def handle_event("save", %{"employee" => params}, socket) do
    save_employee(socket, socket.assigns.live_action, params)
  end

  defp save_employee(socket, :new, params) do
    case HR.create_employee(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee created.")
         |> push_patch(to: ~p"/admin/employees")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_employee(socket, :edit, params) do
    case HR.update_employee(socket.assigns.employee, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Employee updated.")
         |> push_patch(to: ~p"/admin/employees")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_employees(socket) do
    employees = HR.list_employees(department: socket.assigns.department_filter)
    assign(socket, :employees, employees)
  end

  defp department_filter_active?(filter, "all"), do: filter in [nil, ""]
  defp department_filter_active?(filter, dept), do: filter == dept
end
