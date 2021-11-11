defmodule WatwitterWeb.PostComponentTest do
  use WatwitterWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias Watwitter.Timeline.Like
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.DateHelpers

  test "renders posts's body and date" do
    post = insert(:post)

    html = render_component(PostComponent, id: post.id, post: post, current_user: post.user)

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
  end

  test "renders author's name, username, avatar_url" do
    author = insert(:user)
    post = insert(:post, user: author)

    html = render_component(PostComponent, id: post.id, post: post, current_user: post.user)

    assert html =~ author.name
    assert html =~ "@#{author.username}"
    assert html =~ author.avatar_url
  end

  test "renders like button and count" do
    post = insert(:post, likes_count: 1337)

    html = render_component(PostComponent, id: post.id, post: post, current_user: post.user)

    assert html =~ data_role("like-button")
    assert html =~ data_role("like-count")
    assert html =~ "1337"
  end

  test "redners liked button when current user likes post" do
    current_user = insert(:user)
    post = insert(:post, likes: [%Like{user_id: current_user.id}])

    html = render_component(PostComponent, id: post.id, post: post, current_user: current_user)

    assert html =~ data_role("post-liked")
    refute html =~ data_role("like-button")
  end

  test "user can like a post", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    user = insert(:user)
    {:ok, view, _html} = conn |> log_in_user(user) |> live("/")

    view
    |> element("#post-#{post.id} [data-role=like-button]")
    |> render_click()

    assert has_element?(view, "#post-#{post.id} [data-role=like-count]", "1")
  end

  defp data_role(role), do: "data-role=\"#{role}\""
end
