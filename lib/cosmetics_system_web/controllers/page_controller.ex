defmodule CosmeticsSystemWeb.PageController do
  use CosmeticsSystemWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/admin")
  end
end
