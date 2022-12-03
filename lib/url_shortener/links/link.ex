defmodule URLShortener.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "links" do
    field :slug, :string
    field :url, :string
    field :hits, :integer, default: 0

    timestamps()
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> update_change(:url, &String.trim/1)
    |> validate_url()
    |> put_change(:slug, generate_slug())
    |> unique_constraint(:slug)
  end

  def generate_slug(length \\ 8) do
    slug =
      :crypto.strong_rand_bytes(length)
      |> Base.url_encode64()
      |> binary_part(0, length)

    cond do
      String.match?(slug, ~r/[^a-z0-9]/i) ->
        generate_slug(length)

      true ->
        slug
    end
  end

  defp validate_url(changeset) do
    changeset
    |> validate_change(:url, fn :url, url ->
      uri = URI.new(url)

      case uri do
        {:error, _} ->
          [url: "must be a valid URL"]

        {:ok, %URI{scheme: scheme, host: host}} ->
          cond do
            scheme not in ["http", "https"] ->
              [url: "must start with 'http://' or 'https://'"]

            host in [nil, ""] ->
              [url: "must be a valid URL"]

            true ->
              []
          end
      end
    end)
  end
end
