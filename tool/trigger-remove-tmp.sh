#!/bin/sh
: ${TOKEN:=$(ruby -r yaml -e 'puts YAML.load(ARGF.read).dig("github.com", 0, "oauth_token")' ~/.config/hub)}
: ${1?Usage: $0 2.4.9-draft}
curl -sS -X POST -H 'Accept: application/vnd.github.everest-preview+json' -H 'Content-Type: application/json' -H "Authorization: token $TOKEN" https://api.github.com/repos/ruby/actions/dispatches --data '{"event_type": "remove pub/tmp/ruby-${1}"}'
