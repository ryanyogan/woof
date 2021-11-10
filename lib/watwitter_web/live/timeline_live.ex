defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view
  alias Watwitter.{Accounts, Timeline}
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers
  alias WatwitterWeb.ShowPostComponent

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok, assign(socket, current_post: nil, current_user: current_user, posts: posts)}
  end

  @impl true
  def handle_event("select-post", %{"id" => post_id}, socket) do
    id = String.to_integer(post_id)
    current_post = Enum.find(socket.assigns.posts, &(&1.id == id))

    {:noreply, socket |> assign(current_post: current_post)}
  end
end
