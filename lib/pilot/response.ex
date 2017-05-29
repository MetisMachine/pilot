defmodule Pilot.Response do
  
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Plug.Conn
    end
  end

  def redirect(%Plug.Conn{}=conn, url, opts \\ []) do
    response_code = opts[:permanent] && 301 || 302

    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(response_code, "")
    |> Plug.Conn.halt()
  end

  def json(%Plug.Conn{}=conn, data) do
    conn
    |> Plug.Conn.put_resp_header("application/json")
    |> Plug.Conn.send_resp(conn.status || 200, Poison.encode_to_iodata!(data))
    |> Plug.Conn.halt
  end

  def html(%Plug.Conn{}=conn, data) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(conn.status || 200, to_string(data))
    |> Plug.Conn.halt
  end

  def text(%Plug.Conn{}=conn, data) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(conn.status || 200, to_string(data))
    |> Plug.Conn.halt
  end
end