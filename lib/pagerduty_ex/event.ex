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
