defmodule CosmeticsSystemWeb.SimpleTitleLive do
  @moduledoc false

  defmacro __using__(opts) do
    title = Keyword.fetch!(opts, :page_title)

    quote do
      use CosmeticsSystemWeb, :live_view

      use CosmeticsSystemWeb.Embedded,
        behaviour: Phoenix.LiveView,
        template: :index

      @impl true
      def mount(_params, _session, socket) do
        {:ok, assign(socket, :page_title, unquote(title))}
      end
    end
  end
end
