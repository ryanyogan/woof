defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view
  alias Watwitter.{Accounts, Timeline}
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.SVGHelpers
  alias WatwitterWeb.ShowPostComponent
  alias WatwitterWeb.PostComponent

  @impl true
  def mount(params, session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page = 1
    per_page = String.to_integer(params["per_page"] || "10")
    post_ids = Timeline.list_post_ids(page: page, per_page: per_page)

    {:ok,
     assign(socket,
       current_user: current_user,
       new_posts_count: 0,
       new_post_ids: [],
       post_ids: post_ids,
       current_post_id: nil,
       per_page: per_page,
       page: page
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
  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, fn page -> page + 1 end)
      |> update_post_ids()

    {:noreply, socket}
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

  defp update_post_ids(socket) do
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    post_ids = Timeline.list_post_ids(page: page, per_page: per_page)

    socket
    |> update(:post_ids, fn existing -> existing ++ post_ids end)
  end
end
