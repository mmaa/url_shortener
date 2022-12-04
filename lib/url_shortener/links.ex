defmodule URLShortener.Links do
  import Ecto.Query, warn: false

  alias URLShortener.Repo
  alias URLShortener.Links.Link

  def list_links do
    Link
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def get_link!(id) do
    Repo.get!(Link, id)
  end

  def get_link_by_slug!(slug) do
    Repo.get_by!(Link, slug: slug)
  end

  def record_hit!(link) do
    Link
    |> where(id: ^link.id)
    |> Repo.update_all(inc: [hits: 1])
  end

  def create_link(attrs \\ %{}) do
    case %Link{}
         |> Link.changeset(attrs)
         |> Repo.insert() do
      {:error, %{errors: [slug: {_, [{:constraint, :unique}, _]}]}} ->
        create_link(attrs)

      result ->
        result
    end
  end

  def generate_csv do
    list_links()
    |> Enum.map(fn link -> Map.take(link, [:url, :slug, :hits]) end)
    |> CSV.encode(headers: [url: "Original URL", slug: "Short URL", hits: "Hits"])
    |> Enum.to_list()
    |> to_string()
  end

  def delete_link(%Link{} = link) do
    Repo.delete(link)
  end

  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end
end
