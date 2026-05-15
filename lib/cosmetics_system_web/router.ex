defmodule CosmeticsSystemWeb.Router do
  use CosmeticsSystemWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CosmeticsSystemWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_authenticated_user do
    plug :fetch_current_scope_for_admin
  end

  pipeline :require_admin do
    plug :ensure_admin_scope
  end

  scope "/", CosmeticsSystemWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/admin", CosmeticsSystemWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live "/", DashboardLive, :index
    live "/products", ProductsLive, :index
    live "/products/new", ProductsLive, :new
    live "/products/:id/edit", ProductsLive, :edit
    live "/orders", OrdersLive, :index
    live "/orders/:id", OrderDetailLive, :show
    live "/users", UsersLive, :index
    live "/users/new", UsersLive, :new
    live "/users/:id/edit", UsersLive, :edit
    live "/customers", CustomersLive, :index
    live "/customers/new", CustomersLive, :new
    live "/customers/:id/edit", CustomersLive, :edit
    live "/customers/:id", CustomerDetailLive, :show
    live "/employees", EmployeesLive, :index
    live "/employees/new", EmployeesLive, :new
    live "/employees/:id/edit", EmployeesLive, :edit
    live "/suppliers", SuppliersLive, :index
    live "/suppliers/new", SuppliersLive, :new
    live "/suppliers/:id/edit", SuppliersLive, :edit
    live "/purchase-orders", PurchaseOrdersLive, :index
    live "/purchase-orders/new", PurchaseOrdersLive, :new
    live "/purchase-orders/:id/edit", PurchaseOrdersLive, :edit
  end

  scope "/shop", CosmeticsSystemWeb.Shop, as: :shop do
    pipe_through [:browser]

    live "/", HomeLive, :index
    live "/products", ProductsLive, :index
    live "/products/:slug", ProductDetailLive, :show
    live "/categories/:slug", CategoryLive, :show
    live "/cart", CartLive, :index
    live "/checkout", CheckoutLive, :index
    live "/orders/:number", OrderStatusLive, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", CosmeticsSystemWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cosmetics_system, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CosmeticsSystemWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp fetch_current_scope_for_admin(conn, _opts) do
    # TODO: resolve session and assign current_scope when accounts LiveViews exist.
    conn
  end

  defp ensure_admin_scope(conn, _opts) do
    # TODO: enforce admin role from current_scope.
    conn
  end
end
