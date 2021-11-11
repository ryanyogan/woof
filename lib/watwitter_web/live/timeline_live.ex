defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view
  alias Watwitter.{Accounts, Timeline}
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers
  alias WatwitterWeb.ShowPostComponent

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok,
     assign(socket,
       current_post: nil,
       current_user: current_user,
       posts: posts,
       new_posts_count: 0
     )}
  end

  @impl true
  def handle_params(%{"post_id" => post_id}, _, socket) do
    id = String.to_integer(post_id)
    current_post = Enum.find(socket.assigns.posts, &(&1.id == id))

    {:noreply, socket |> assign(current_post: current_post)}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:post_created, _post}, socket) do
    {:noreply, update(socket, :new_posts_count, fn count -> count + 1 end)}
  end
end
