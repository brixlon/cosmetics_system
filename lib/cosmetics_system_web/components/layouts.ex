defmodule CosmeticsSystemWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use CosmeticsSystemWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="admin-shell">
      <%# ── Sidebar ─────────────────────────────────────── %>
      <aside class="admin-sidebar">
        <div class="admin-sidebar__brand">
          <div class="admin-sidebar__logo">
            <svg viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="7" cy="7" r="5" stroke="currentColor" stroke-width="1.5"/>
              <circle cx="7" cy="7" r="2" fill="currentColor"/>
            </svg>
          </div>
          <div>
            <span class="admin-sidebar__brand-name"><span>Luminae</span> Admin</span>
          </div>
        </div>

        <div class="admin-sidebar__section">
          <p class="admin-sidebar__section-label">Overview</p>
          <ul class="admin-sidebar__nav">
            <li>
              <.link navigate={~p"/admin"} class="admin-sidebar__link">
                <.icon name="hero-chart-bar-square" class="admin-sidebar__link-icon" />
                Dashboard
              </.link>
            </li>
          </ul>
        </div>

        <div class="admin-sidebar__section">
          <p class="admin-sidebar__section-label">Commerce</p>
          <ul class="admin-sidebar__nav">
            <li>
              <.link navigate={~p"/admin/orders"} class="admin-sidebar__link">
                <.icon name="hero-shopping-bag" class="admin-sidebar__link-icon" />
                Orders
              </.link>
            </li>
            <li>
              <.link navigate={~p"/admin/products"} class="admin-sidebar__link">
                <.icon name="hero-squares-2x2" class="admin-sidebar__link-icon" />
                Products
              </.link>
            </li>
            <li>
              <.link navigate={~p"/admin/customers"} class="admin-sidebar__link">
                <.icon name="hero-users" class="admin-sidebar__link-icon" />
                Customers
              </.link>
            </li>
          </ul>
        </div>

        <div class="admin-sidebar__section">
          <p class="admin-sidebar__section-label">Operations</p>
          <ul class="admin-sidebar__nav">
            <li>
              <.link navigate={~p"/admin/suppliers"} class="admin-sidebar__link">
                <.icon name="hero-truck" class="admin-sidebar__link-icon" />
                Suppliers
              </.link>
            </li>
            <li>
              <.link navigate={~p"/admin/purchase-orders"} class="admin-sidebar__link">
                <.icon name="hero-document-text" class="admin-sidebar__link-icon" />
                Purchase Orders
              </.link>
            </li>
            <li>
              <.link navigate={~p"/admin/employees"} class="admin-sidebar__link">
                <.icon name="hero-identification" class="admin-sidebar__link-icon" />
                Employees
              </.link>
            </li>
          </ul>
        </div>

        <div class="admin-sidebar__footer">
          <a href="#" class="admin-sidebar__user">
            <div class="admin-sidebar__avatar">A</div>
            <div>
              <p class="admin-sidebar__user-name">Admin</p>
              <p class="admin-sidebar__user-role">Administrator</p>
            </div>
          </a>
        </div>
      </aside>

      <%# ── Main ────────────────────────────────────────── %>
      <div class="admin-main">
        <header class="admin-topbar">
          <div class="admin-topbar__search">
            <svg class="admin-topbar__search-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <input type="search" placeholder="Search…" />
          </div>
          <div class="admin-topbar__actions">
            <.link navigate={~p"/shop"} class="admin-topbar__icon-btn" title="View shop">
              <.icon name="hero-arrow-top-right-on-square" class="w-4 h-4" />
            </.link>
            <button type="button" class="admin-topbar__icon-btn" title="Notifications">
              <.icon name="hero-bell" class="w-4 h-4" />
              <span class="admin-topbar__notif-dot"></span>
            </button>
            <Layouts.theme_toggle />
          </div>
        </header>

        <main class="admin-content">
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        type="button"
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        type="button"
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        type="button"
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
