defmodule URLShortenerWeb.LinkController do
  use URLShortenerWeb, :controller

  alias URLShortener.Links
  alias URLShortener.Links.Link

  def index(conn, _params) do
    links = Links.list_links()
    render(conn, :index, links: links)
  end

  def download(conn, _params) do
    csv = Links.generate_csv()
    send_download(conn, {:binary, csv}, filename: "stats.csv")
  end

  def new(conn, _params) do
    changeset = Links.change_link(%Link{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case Links.create_link(link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Short URL created successfully.")
        |> put_flash(:short_url, URLShortenerWeb.Endpoint.url() <> "/" <> link.slug)
        |> redirect(to: ~p"/")

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
