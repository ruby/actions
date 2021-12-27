#!/bin/sh
if [ -f ~/.config/hub ]; then
  : ${TOKEN:=$(ruby -r yaml -e 'puts YAML.load(ARGF.read).dig("github.com", 0, "oauth_token")' ~/.config/hub)}
fi
if [ -f ~/.config/gh/hosts.yml ]; then
  : ${TOKEN:=$(ruby -r yaml -e 'puts YAML.load(ARGF.read).dig("github.com", "oauth_token")' ~/.config/gh/hosts.yml)}
fi

: ${1?Usage: $0 2.4.9-draft}
curl -sS -X POST -H 'Accept: application/vnd.github.everest-preview+json' -H 'Content-Type: application/json' -H "Authorization: token $TOKEN" https://api.github.com/repos/ruby/actions/dispatches --data '{"event_type": "Remove pub/tmp/ruby-'"${1}"'"}'
