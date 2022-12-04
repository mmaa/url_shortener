defmodule URLShortener.LinksTest do
  use URLShortener.DataCase

  alias URLShortener.Repo
  alias URLShortener.Links

  describe "links" do
    alias URLShortener.Links.Link

    import URLShortener.LinksFixtures

    @invalid_attrs %{url: "asdf"}

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Links.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Links.get_link!(link.id) == link
    end

    test "record_hit!/1 increments hits on the link" do
      link = link_fixture()
      Links.record_hit!(link)
      assert Repo.reload(link).hits == 1
    end

    test "create_link/1 with valid data creates a link" do
      valid_attrs = %{url: "http://www.example.com"}

      assert {:ok, %Link{} = link} = Links.create_link(valid_attrs)
      assert link.url == "http://www.example.com"
      assert link.slug != nil
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Links.create_link(@invalid_attrs)
    end

    test "generate_csv/0 returns a CSV string of all links" do
      link = link_fixture()

      assert Links.generate_csv() ==
               "Original URL,Short URL,Hits\r\nhttp://www.example.com,#{link.slug},0\r\n"
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Links.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Links.change_link(link)
    end
  end
end
