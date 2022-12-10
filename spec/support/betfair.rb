# frozen_string_literal: true

#
# $Id$
#
def stub_betfair_login(name = "Soccer", children = [])
  stub_request(:post, "https://identitysso-cert.betfair.com/api/certlogin")
    .with(
      body: "username=fred&password=password",
    )
    .to_return(body: {
      sessionToken: "token",
      loginStatus: "SUCCESS",
    }.to_json)

  stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listEventTypes/")
    .with(
      body: { filter: {} }.to_json,
    )
    .to_return(body: [eventType: { name: "Soccer", id: 1 }].to_json)

  stub_request(:get, "https://api.betfair.com/exchange/betting/rest/v1/en/navigation/menu.json")
    .to_return(body: { type: "GROUP", name: "ROOT", id: 0, children: [{ type: "EVENT_TYPE", name: name, children: children }] }.to_json)
end
