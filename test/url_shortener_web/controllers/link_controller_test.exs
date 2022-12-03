defmodule URLShortenerWeb.LinkControllerTest do
  use URLShortenerWeb.ConnCase

  import URLShortener.LinksFixtures

  @create_attrs %{url: "http://www.example.com"}
  @invalid_attrs %{url: "asdf"}

  describe "index" do
    test "lists all links", %{conn: conn} do
      conn = get(conn, ~p"/stats")
      assert html_response(conn, 200) =~ "Stats"
    end
  end

  describe "download" do
    test "downloads a csv", %{conn: conn} do
      conn = get(conn, ~p"/download")
      assert response(conn, 200)
      assert response_content_type(conn, :csv)
    end
  end

  describe "new link" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Shorten URL"
    end
  end

  describe "create link" do
    test "redirects to stats when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/", link: @create_attrs)
      assert redirected_to(conn) == ~p"/stats"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/", link: @invalid_attrs)
      assert html_response(conn, 200) =~ "Shorten URL"
    end
  end

  describe "show link" do
    test "redirects to URL when slug is found", %{conn: conn} do
      link = link_fixture()
      conn = get(conn, ~p"/#{link.slug}")
      assert redirected_to(conn) == link.url
    end

    test "returns 404 when slug is not found", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/asdf")
      end
    end
  end

  describe "delete link" do
    setup [:create_link]

    test "deletes chosen link", %{conn: conn, link: link} do
      conn = delete(conn, ~p"/#{link}")
      assert redirected_to(conn) == ~p"/stats"

      assert_error_sent 404, fn ->
        get(conn, ~p"/#{link}")
      end
    end
  end

  defp create_link(_) do
    link = link_fixture()
    %{link: link}
  end
end
