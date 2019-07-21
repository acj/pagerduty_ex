defmodule PagerDutyEx do
  @moduledoc """
  An API for interacting with the PagerDuty service.
  """

  require Logger
  use Retry

  @event_api_url "https://events.pagerduty.com/v2/enqueue"

  def trigger_event(%PagerDutyEx.Event{} = event) do
    event = decorate_with_integration_key(event)

    case post_with_retry(event) do
      {:ok, response} ->
        Logger.debug("#{__MODULE__}.trigger_event: Sent event to PagerDuty: #{event.payload.summary}")
        {:ok, response}
      error ->
        Logger.error("#{__MODULE__}.trigger_event: Failed with error: #{inspect error}")
        error
    end
  end

  def acknowledge_event(%PagerDutyEx.Event{} = event) do
    event = decorate_with_integration_key(event)

    payload = %{
      routing_key: event.routing_key,
      dedup_key: event.dedup_key,
      event_action: "acknowledge"
    }

    post_with_retry(payload)
  end

  def resolve_event(%PagerDutyEx.Event{} = event) do
    event = decorate_with_integration_key(event)

    payload = %{
      routing_key: event.routing_key,
      dedup_key: event.dedup_key,
      event_action: "resolve"
    }

    post_with_retry(payload)
  end

  defp post_with_retry(payload) do
    retry with: exponential_backoff() |> randomize |> expiry(15_000) do
      post(payload)
    after
      result -> result
    else
      error -> error
    end
  end

  defp post(payload) do
    case HTTPoison.post(event_url(), Poison.encode!(payload), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{body: body, status_code: 202}} ->
        body = atomize_keys(Poison.decode!(body))
        {:ok, struct!(PagerDutyEx.Response, body)}

      {:ok, %HTTPoison.Response{body: body, status_code: s}} ->
        if s == 429, do: Logger.warn("#{__MODULE__}.post: Request throttled by PagerDuty API")
        {:error, struct!(PagerDutyEx.Response, Poison.decode!(body))}

      {:error, error} ->
        Logger.error("#{__MODULE__}.post: Unexpected error: #{inspect error}")
        {:error, error}
    end
  end

  defp decorate_with_integration_key(event) do
    %{event | routing_key: integration_key()}
  end

  defp event_url do
    case Application.get_env(:pagerduty_ex, :event_api_url) do
      nil -> @event_api_url
      url -> url
    end
  end

  def atomize_keys(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, val}
        true -> {String.to_atom(key), val}
      end
    end
  end

  defp integration_key do
    case Application.get_env(:pagerduty_ex, :integration_key) do
      {:system, env_var} -> System.get_env(env_var)
      nil                -> raise "You need to provide a PagerDutyEx integration key"
      val                -> val
    end
  end
end
