defmodule SimpleHttpServer do
  @type path_match :: String.t
  @type req :: :http_req
  @type status :: non_neg_integer
  @type headers :: [{String.t, String.t}]
  @type body :: String.t
  @type handler :: (req -> {status, headers, body})

  @spec mount(port :: non_neg_integer, path_handler_map :: %{optional(path_match) => handler}) :: :ok
  @spec serve_static_directory(args :: %{required(String.t) => path_match, optional(String.t) => port}) :: :ok

  @default_port 4040

  @doc """
  Spawns a simple cowboy server. Cowboy is a bit unwieldy to use directly, and HttpServer only
  allows you to define one response function. SimpleHttpServer allows you to quickly and easily
  spin up a quick HTTP app.
  """
  def mount(port, path_handler_map) do
    paths_list =
      path_handler_map
      |> Enum.map(fn {path, fun} ->
        {path, CowboyFunctionHandler, fun}
      end)

    host = {:_, paths_list}
    routes = [host]

    dispatch = :cowboy_router.compile(routes)

    ranch_opts = [{:port, port}]
    cowboy_opts = [{:env, [{:dispatch, dispatch}]}]
    {:ok, _} = :cowboy.start_http("simple_http_server_#{port}", 10, ranch_opts, cowboy_opts)
  end

  @doc """
  Spawns a cowboy server that serves all files in a given directory.
  """
  def serve_static_directory(args) do
    Application.ensure_started(:crypto)
    Application.ensure_started(:cowboy)

    port = args[:port] || @default_port

    dispatch = :cowboy_router.compile([
      {:_,
        [
          {"/[...]", :cowboy_static, {:dir, args[:directory]}},
        ]
      }
    ])

    ranch_opts = [{:port, port}]
    cowboy_opts = [{:env, [{:dispatch, dispatch}]}]
    {:ok, _} = :cowboy.start_http("simple_http_server_#{port}", 10, ranch_opts, cowboy_opts)
  end

  def stop, do: stop(@default_port)
  def stop(port) do
    :ok = :cowboy.stop_listener("simple_http_server_#{port}")
  end
end
