defmodule PilotTest do
  require Logger
  use ExUnit.Case

  import Plug.Conn
  import Plug.Test
  
  use Pilot.Responses

  doctest Pilot

  test "ensure redirect status and headers are set." do
    test_conn()
    |> redirect("/test/path")
    |> assert_redirect("/test/path")
  end

  test "ensure status is property set for return response" do
    test_conn()
    |> status(404)
    |> assert_status(404)
  end

  test "ensure text body and text/plain content type is in the response" do
    assert test_conn() 
           |> text(:ok, "testing text")
           |> assert_state()
           |> assert_status(200)
           |> assert_content_type("text/plain")
           |> sent_resp()
           |> elem(2)
           |> String.equivalent?("testing text")
  end

  test "ensure html body and text/html content type is in the response" do
     assert test_conn() 
            |> html(:ok, "<h1>testing html</h1>")
            |> assert_state()
            |> assert_status(200)
            |> assert_content_type("text/html")
            |> sent_resp()
            |> elem(2)
            |> String.equivalent?("<h1>testing html</h1>")
    
  end

  test "ensure json body and content type" do
    assert test_conn()
           |> json(:ok, %{hello: "world"})
           |> assert_state()
           |> assert_status(200)
           |> assert_content_type("application/json")
           |> sent_resp()
           |> elem(2)
           |> String.equivalent?(Poison.encode!(%{hello: "world"}))
  end

  defp test_conn(method \\ :get, path \\ "/path") do
    conn(method, path)
  end

  defp assert_content_type(conn, type) do
    assert Plug.Conn.get_resp_header(conn, "content-type")
           |> to_string()
           |> String.contains?(type)

    conn  
  end

  defp assert_state(conn, state \\ :sent) do
    assert conn.state == state

    conn
  end

  defp assert_status(conn, status) do
    assert conn.status == status

    conn  
  end

  defp assert_redirect(conn, status \\ 302, to) do
    conn
    |> assert_state()    
    |> assert_status(status)

    assert Plug.Conn.get_resp_header(conn, "location") == [to]

    conn
  end
end
