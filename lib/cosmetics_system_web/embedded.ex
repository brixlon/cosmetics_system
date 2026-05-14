defmodule CosmeticsSystemWeb.Embedded do
  @moduledoc false

  defmacro __using__(opts) do
    behaviour = Keyword.fetch!(opts, :behaviour)
    template = Keyword.fetch!(opts, :template)

    quote do
      embed_templates("*")

      @impl unquote(behaviour)
      def render(assigns) do
        apply(__MODULE__, unquote(template), [assigns])
      end
    end
  end
end
