defmodule CosmeticsSystem.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CosmeticsSystemWeb.Telemetry,
      CosmeticsSystem.Repo,
      {DNSCluster, query: Application.get_env(:cosmetics_system, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CosmeticsSystem.PubSub},
      # Start a worker by calling: CosmeticsSystem.Worker.start_link(arg)
      # {CosmeticsSystem.Worker, arg},
      # Start to serve requests, typically the last entry
      CosmeticsSystemWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CosmeticsSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CosmeticsSystemWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
