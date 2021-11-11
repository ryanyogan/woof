defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view
  alias Watwitter.{Accounts, Timeline}
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers
  alias WatwitterWeb.ShowPostComponent
  alias WatwitterWeb.PostComponent

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    current_user = Accounts.get_user_by_session_token(session["user_token"])
    post_ids = Timeline.list_post_ids()

    {:ok,
     assign(socket,
       current_user: current_user,
       new_posts_count: 0,
       new_post_ids: [],
       post_ids: post_ids,
       current_post_id: nil
     )}
  end

  @impl true
  def handle_params(%{"post_id" => post_id}, _, socket) do
    id = String.to_integer(post_id)

    {:noreply, socket |> assign(current_post_id: id)}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> update(:post_ids, fn post_ids -> socket.assigns.new_post_ids ++ post_ids end)
     |> assign(:new_post_ids, [])
     |> assign(:new_posts_count, 0)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply,
     socket
     |> update(:new_posts_count, &(&1 + 1))
     |> update(:new_post_ids, &[post.id | &1])}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    send_update(PostComponent, id: post.id)

    {:noreply, socket}
  end
end
