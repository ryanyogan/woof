defmodule WatwitterWeb.PostComponentTest do
  use WatwitterWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias Watwitter.Timeline.Like
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.DateHelpers

  test "renders posts's body and date" do
    post = insert(:post)

    html = render_component(PostComponent, post: post, current_user: post.user)

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
  end

  test "renders author's name, username, avatar_url" do
    author = insert(:user)
    post = insert(:post, user: author)

    html = render_component(PostComponent, post: post, current_user: post.user)

    assert html =~ author.name
    assert html =~ "@#{author.username}"
    assert html =~ author.avatar_url
  end

  test "renders like button and count" do
    post = insert(:post, likes_count: 1337)

    html = render_component(PostComponent, post: post, current_user: post.user)

    assert html =~ data_role("like-button")
    assert html =~ data_role("like-count")
    assert html =~ "1337"
  end

  test "redners liked button when current user likes post" do
    current_user = insert(:user)
    post = insert(:post, likes: [%Like{user_id: current_user.id}])

    html = render_component(PostComponent, post: post, current_user: current_user)

    assert html =~ data_role("post-liked")
    refute html =~ data_role("like-button")
  end

  defp data_role(role), do: "data-role=\"#{role}\""
end