defmodule CosmeticsSystem.Notifications do
  @moduledoc """
  Notification helpers for system alerts and broadcast events.
  """

  def low_stock_alert(variant) do
    Phoenix.PubSub.broadcast(CosmeticsSystem.PubSub, "notifications", {:low_stock, variant})
    :ok
  end
end
