defmodule CodebattleWeb.MainChannel do
  @moduledoc false
  use CodebattleWeb, :channel

  alias CodebattleWeb.Presence

  def join("main", _payload, socket) do
    current_user = socket.assigns.current_user

    if !current_user.is_guest do
      topic = "main:#{current_user.id}"
      Codebattle.PubSub.subscribe(topic)
      send(self(), :after_join)
    end

    {:ok, %{}, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.current_user.id, %{
        online_at: inspect(System.system_time(:second)),
        user: socket.assigns.current_user,
        id: socket.assigns.current_user.id
      })

    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end
end
