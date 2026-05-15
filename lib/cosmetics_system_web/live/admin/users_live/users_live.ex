defmodule CosmeticsSystemWeb.Admin.UsersLive do
  use CosmeticsSystemWeb, :live_view

  alias CosmeticsSystem.Accounts
  alias CosmeticsSystem.Accounts.User

  use CosmeticsSystemWeb.Embedded,
    behaviour: Phoenix.LiveView,
    template: :index

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Accounts")
     |> assign(:role_filter, nil)
     |> load_users()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:user, %User{})
    |> assign(:changeset, Accounts.change_user_registration(%User{}))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(id)

    socket
    |> assign(:user, user)
    |> assign(:changeset, Accounts.change_user_registration(user))
  end

  @impl true
  def handle_event("filter_role", %{"role" => role}, socket) do
    role = if role == "", do: nil, else: role
    {:noreply, socket |> assign(:role_filter, role) |> load_users()}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    save_user(socket, socket.assigns.live_action, params)
  end

  defp save_user(socket, :new, params) do
    case Accounts.register_user(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created.")
         |> push_patch(to: ~p"/admin/users")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user(socket, :edit, params) do
    case Accounts.update_user_registration(socket.assigns.user, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account updated.")
         |> push_patch(to: ~p"/admin/users")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp load_users(socket) do
    users = Accounts.list_users(role: socket.assigns.role_filter)
    assign(socket, :users, users)
  end

  defp role_filter_active?(filter, "all"), do: filter in [nil, ""]
  defp role_filter_active?(filter, role), do: filter == role

  defp link_status(%User{} = user) do
    cond do
      user.customer -> "Customer profile"
      user.employee -> "Employee profile"
      true -> "Unlinked"
    end
  end
end
