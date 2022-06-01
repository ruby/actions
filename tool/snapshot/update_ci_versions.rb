#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open-uri"

RUBY_VERSIONS_FILE = "https://raw.githubusercontent.com/ruby/setup-ruby/master/ruby-builder-versions.json"

def create_files
  json = JSON.parse(URI.open(RUBY_VERSIONS_FILE) {|f| f.read})
  cruby = parse_cruby(json)
  jruby = parse_jruby(json)
  truffleruby = parse_truffleruby(json)

  File.open('cruby.json', 'w') do |f|
    f.puts cruby.to_json
  end

  File.open('cruby-jruby.json', 'w') do |f|
    f.puts (cruby + jruby).to_json
  end

  File.open('cruby-truffleruby.json', 'w') do |f|
    f.puts (cruby + truffleruby).to_json
  end

  File.open('all.json', 'w') do |f|
    f.puts (cruby + jruby + truffleruby).to_json
  end
end

def parse_cruby(json)
  if 0 < Time.now.month && Time.now.month < 4
    version_count = 4
  else
    version_count = 3
  end

  json["ruby"].select{|v| v =~ /\d\.\d.\d$/}.map{|v| v[0..2]}.uniq.last(version_count) + ["head"]
end

def parse_jruby(json)
  [json["jruby"].reject{|v| v == "head"}.last, "head"].map{|v| "jruby-" + v }
end

def parse_truffleruby(json)
  [json["truffleruby"].reject{|v| v == "head"}.last, "head"].map{|v| "truffleruby-" + v }
end

def update_versions
  create_files
end

if __FILE__ == $0
  update_versions
end
