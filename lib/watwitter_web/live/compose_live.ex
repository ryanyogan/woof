defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  alias Watwitter.{Accounts, Timeline}
  alias Watwitter.Timeline.Post
  alias WatwitterWeb.SVGHelpers

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    changeset = Timeline.change_post(%Post{})

    socket =
      socket
      |> assign(current_user: current_user, changeset: changeset)
      |> allow_upload(:photos, accept: ~w(.jpg .jpeg .png), max_entries: 2)

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user

    photo_urls =
      consume_uploaded_entries(socket, :photos, fn %{path: path}, entry ->
        dest = Path.join(uploads_dir(), filename(entry))
        File.cp!(path, dest)

        Routes.static_path(socket, "/uploads/#{filename(entry)}")
      end)

    params =
      post_params
      |> Map.put("user_id", current_user.id)
      |> Map.put("photo_urls", photo_urls)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        {:noreply, push_redirect(socket, to: Routes.timeline_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    params = Map.put(post_params, "user_id", current_user.id)

    changeset =
      %Post{}
      |> Timeline.change_post(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  defp uploads_dir do
    Application.app_dir(:watwitter, "priv/static/uploads")
  end

  defp filename(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    "#{entry.uuid}.#{ext}"
  end
end
