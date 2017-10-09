defmodule PagerDutyExTest do
  use ExUnit.Case, async: false

  doctest PagerDutyEx

  @api_endpoint "/v2/enqueue"
  @integration_key "12345"
  @dummy_event %PagerDutyEx.Event{
    routing_key: @integration_key,
    event_action: "trigger",
    dedup_key: "abc",
    payload: %PagerDutyEx.Event.Payload{
      summary: "This is a simple summary",
      source: "foo.wistia.land",
      severity: "warning",
      timestamp: "2015-07-17T08:42:58.315+0000",
      component: "tests",
      group: "modernpastry",
      class: "tests",
      custom_details: %{foo: "bar"},
    }
  }
  @dummy_acknowledge_payload %{
    routing_key:  @dummy_event.routing_key,
    dedup_key:    @dummy_event.dedup_key,
    event_action: "acknowledge"
  }
  @dummy_resolve_payload %{
    routing_key:  @dummy_event.routing_key,
    dedup_key:    @dummy_event.dedup_key,
    event_action: "resolve"
  }
  @port 4200
  @successful_response %PagerDutyEx.Response{
    status: "success",
    message: "Event processed",
    dedup_key: @dummy_event.dedup_key
  }

  setup do
    Application.put_env(:pagerduty_ex, :event_api_url, "http://0.0.0.0:#{@port}#{@api_endpoint}")
    Application.put_env(:pagerduty_ex, :integration_key, @integration_key)
  end

  describe "trigger_event/1" do
    test "raises if the integration key isn't provided" do
      Application.put_env(:pagerduty_ex, :integration_key, nil)
      assert_raise(RuntimeError, fn ->
        PagerDutyEx.trigger_event(@dummy_event)
      end)
    end

    test "posts the correct body to the endpoint" do
      assert_api_returns(
        @api_endpoint,
        fn -> PagerDutyEx.trigger_event(@dummy_event) end,
        Poison.encode!(@dummy_event),
        @successful_response
      )
    end
  end

  describe "acknowledge_event/1" do
    test "raises if the integration key isn't provided" do
      Application.put_env(:pagerduty_ex, :integration_key, nil)
      assert_raise(RuntimeError, fn ->
        PagerDutyEx.acknowledge_event(@dummy_event)
      end)
    end

    test "posts the correct body to the endpoint" do
      assert_api_returns(
        @api_endpoint,
        fn -> PagerDutyEx.acknowledge_event(@dummy_event) end,
        Poison.encode!(@dummy_acknowledge_payload),
        @successful_response
      )
    end
  end

  describe "resolve_event/1" do
    test "raises if the integration key isn't provided" do
      Application.put_env(:pagerduty_ex, :integration_key, nil)
      assert_raise(RuntimeError, fn ->
        PagerDutyEx.resolve_event(@dummy_event)
      end)
    end

    test "posts the correct body to the endpoint" do
      assert_api_returns(
        @api_endpoint,
        fn -> PagerDutyEx.resolve_event(@dummy_event) end,
        Poison.encode!(@dummy_resolve_payload),
        @successful_response
      )
    end
  end

  @doc "Verifies that the API endpoint returns the expected response to a given operation"
  def assert_api_returns(endpoint, yield, expected_payload, expected_response) do
    parent = self()
    {:ok, http_pid} = SimpleHttpServer.mount(@port, %{
      endpoint => fn(req) ->
        body = elem(req, 21)
        send(parent, {:received_request, body})

        response = %{status: "success", message: "Event processed", dedup_key: @dummy_event.dedup_key}
        {202, [], Poison.encode!(response)}
      end
    })

    ExUnit.CaptureLog.capture_log(fn ->
      {:ok, ^expected_response} = yield.()
    end)

    payload =
      receive do
        {:received_request, payload} -> payload
      end

    assert payload == expected_payload

    SimpleHttpServer.stop(@port)
    assert_have_exited [http_pid]
  end

  @doc "Will block until the given processes are down"
  def assert_have_exited(pids) do
    Enum.each(pids, fn(pid) ->
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}, 5_000
    end)
  end
end
