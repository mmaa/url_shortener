defmodule URLShortener.LinksFixtures do
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        url: "http://www.example.com"
      })
      |> URLShortener.Links.create_link()

    link
  end
end
