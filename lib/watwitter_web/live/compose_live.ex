defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  alias Watwitter.{Accounts, Timeline}
  alias Watwitter.Timeline.Post
  alias WatwitterWeb.SVGHelpers

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    changeset = Timeline.change_post(%Post{})

    {:ok, assign(socket, current_user: current_user, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    params = Map.put(post_params, "user_id", current_user.id)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        {:noreply, push_redirect(socket, to: Routes.timeline_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
