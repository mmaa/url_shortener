defmodule URLShortenerWeb.LinkController do
  use URLShortenerWeb, :controller

  alias URLShortener.Links
  alias URLShortener.Links.Link

  def index(conn, _params) do
    links = Links.list_links()
    render(conn, :index, links: links)
  end

  def new(conn, _params) do
    changeset = Links.change_link(%Link{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Links.create_link(link_params) do
      {:ok, link} ->
        conn
        |> put_flash(
          :info,
          "Shortened link '#{link.slug}' for '#{link.url}' created successfully."
        )
        |> redirect(to: ~p"/stats")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    link = Links.get_link_by_slug!(slug)

    Task.start(fn -> Links.record_hit!(link) end)

    redirect(conn, external: link.url)
  end

  def delete(conn, %{"id" => id}) do
    link = Links.get_link!(id)
    {:ok, _link} = Links.delete_link(link)

    conn
    |> put_flash(:info, "Link deleted successfully.")
    |> redirect(to: ~p"/stats")
  end
end
