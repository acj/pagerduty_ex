# PagerdutyEx

[![Hex.pm](https://img.shields.io/hexpm/v/pagerduty_ex.svg)](https://hex.pm/packages/pagerduty_ex)
[![Build Docs](https://img.shields.io/badge/hexdocs-release-blue.svg)](https://hexdocs.pm/pagerduty_ex/PagerDutyEx.html)
[![Build Status](https://travis-ci.org/acj/pagerduty_ex.svg?branch=master)](https://travis-ci.org/acj/pagerduty_ex)
[![Coverage Status](https://coveralls.io/repos/github/acj/pagerduty_ex/badge.svg?branch=master)](https://coveralls.io/github/acj/pagerduty_ex?branch=master)

A simple client library for PagerDuty API v2.

## Getting Started

Find the integration key for your PagerDuty account and add it to your app's `config.exs`:

```ex
# Using the literal key
config :pagerduty_ex,
  integration_key: abc123

# If you're using environment variables
config :pagerduty_ex,
  integration_key: {:system, "PAGERDUTY_INTEGRATION_KEY"}
```

The `PagerDutyEx` API has three exposed functions:

```ex
def trigger_event(%PagerDutyEx.Event{} = event) do ...
def acknowledge_event(%PagerDutyEx.Event{} = event) do ...
def resolve_event(%PagerDutyEx.Event{} = event) do ...
```

These do what you would expect, and they take an `Event` struct of the following form:

```ex
defmodule PagerDutyEx.Event do
  defstruct [
    routing_key: nil,  # Required: "Integration Key" listed on the Events API V2 integration's detail page
    event_action: nil, # Required: Supported values are "trigger", "acknowledge", and "resolve"
    dedup_key: nil,    # Deduplication key for correlating triggers and resolves
    payload: nil,      # The event details. See the Event.Payload struct below.
    images: [],        # List of images to include
    links: [],         # List of links to include
  ]
end

defmodule PagerDutyEx.Event.Payload do
  @enforce_keys [:summary, :source, :severity]
  defstruct [
    summary: nil,        # A brief text summary of the event
    source: nil,         # Hostname or FQDN
    severity: nil,       # Supported values: "critical", "error", "warning", or "info"
    timestamp: nil,      # The time at which the event was generated, e.g. 2015-07-17T08:42:58.315+0000
    component: nil,      # Component that is responsible for the event, e.g. "mysql" or "eth0"
    group: nil,          # Logical grouping of components of a service, e.g. "app-stack"
    class: nil,          # The class/type of the event, e.g. "ping failure" or "cpu load"
    custom_details: nil, # Additional details about the event
  ]
end
```

## Contributing

Contributions are welcome. If you're having trouble or have a feature request, please open an issue. If you have a bug fix or a feature to add, please fork this repository and open a pull request.

## License

MIT