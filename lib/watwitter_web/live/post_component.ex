defmodule WatwitterWeb.PostComponent do
  use WatwitterWeb, :live_component
  alias WatwitterWeb.{DateHelpers, SVGHelpers}
  alias Watwitter.Timeline

  @impl true
  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)
    posts = Timeline.get_posts(list_of_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(
        assigns,
        :post,
        Enum.find(posts, &(&1.id == assigns.id))
      )
    end)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <img class="avatar" src="<%= @post.user.avatar_url %>">
      <div class="post-content">
        <div class="post-header">
          <div class="post-user-info">
            <span class="post-user-name">
              <%= @post.user.name %>
            </span>
            <span class="post-user-username">
              @<%= @post.user.username %>
            </span>
          </div>

          <div class="post-date-info">
            <span class="post-date-separator">.</span>
            <span class="post-date">
              <%= DateHelpers.format_short(@post.inserted_at) %>
            </span>
          </div>
        </div>

        <%= live_patch to: Routes.timeline_path(@socket, :index, post_id: @post.id), data: [role: "show-post"] do %>
          <div class="post-body">
            <%= @post.body %>
          </div>
        <% end %>

        <div class="post-actions">
          <a class="post-action" href="#">
            <%= SVGHelpers.reply_svg() %>
          </a>
          <a class="post-action" href="#">
            <%= SVGHelpers.repost_svg() %>
            <span class="post-action-count" data-role="repost-count">
              <%= @post.reposts_count %>
            </span>
          </a>
          <%= if current_user_liked?(@post, @current_user) do %>
            <a class="post-action post-liked" href="#" data-role="post-liked">
              <%= SVGHelpers.liked_svg() %>
              <span class="post-action-count" data-role="like-count">
                <%= @post.likes_count %>
              </span>
            </a>
          <% else %>
            <a class="post-action" href="#" phx-click="like" phx-target="<%= @myself %>" data-role="like-button">
              <%= SVGHelpers.like_svg() %>
              <span class="post-action-count" data-role="like-count">
                <%= @post.likes_count %>
              </span>
            </a>
          <% end %>
          <a class="post-action" href="#">
            <%= SVGHelpers.export_svg() %>
          </a>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("like", _, socket) do
    current_user = socket.assigns.current_user
    post = socket.assigns.post
    updated_post = Timeline.like_post!(post, current_user)

    {:noreply, assign(socket, :post, updated_post)}
  end

  defp current_user_liked?(post, user) do
    user.id in Enum.map(post.likes, & &1.user_id)
  end
end
