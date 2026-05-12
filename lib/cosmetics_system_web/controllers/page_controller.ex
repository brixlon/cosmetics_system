defmodule CosmeticsSystemWeb.PageController do
  use CosmeticsSystemWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
