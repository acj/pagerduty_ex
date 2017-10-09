defmodule CowboyFunctionHandler do
  def init(_type, req, fun) do
    {:ok, req, fun}
  end

  def handle(req, fun) do
    {code, headers, body} = fun.(req)
    {:ok, reply} = :cowboy_req.reply(code, headers, body, req)
    {:ok, reply, fun}
  end

  def terminate(_, _, _), do: :ok
end
