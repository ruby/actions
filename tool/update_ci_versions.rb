#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "aws-sdk-s3"
  gem "rexml"
end

require "json"
require "open-uri"

require 'aws-sdk-s3'

RUBY_VERSIONS_FILE = "https://raw.githubusercontent.com/ruby/setup-ruby/master/ruby-builder-versions.json"

def create_files
  json = JSON.parse(URI.open(RUBY_VERSIONS_FILE) {|f| f.read})
  cruby = parse_cruby(json)
  jruby = ["jruby", "jruby-head"]
  truffleruby = ["truffleruby", "truffleruby-head"]

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

def upload_index(bucket)
  STDERR.puts "Upload pub/misc/ci_versions/*.json"
  %w(cruby.json cruby-jruby.json cruby-truffleruby.json all.json).each do |file|
    bucket.object("pub/misc/ci_versions/#{file}").upload_file(file)
  end
end

def purge_fastly
  %w(cruby.json cruby-jruby.json cruby-truffleruby.json all.json).each do |file|
    cmd = %W(curl -X PURGE -H Fastly-Soft-Purge:1 https://cache.ruby-lang.org/pub/misc/ci_versions/#{file})
    STDERR.puts "Executing #{cmd}"
    system(*cmd)
  end
end

def update_versions
  s3 = Aws::S3::Resource.new(region:'us-east-1')
  bucket = s3.bucket('ftp.r-l.o')
  create_files
  upload_index(bucket)
  purge_fastly
end

if __FILE__ == $0
  update_versions
end
