#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerates https://cache.ruby-lang.org/pub/ruby/binaries/index.json
# from the objects under pub/ruby/binaries/mswin64/.  The index follows
# the shape of PEP 773 (pymanager) feeds: a flat list of builds, newest
# first, each carrying resolution tags.  The file is always generated
# from scratch; S3 is the single source of truth, so a lost or corrupt
# index heals on the next run.
#
# Tag vocabulary (follows ruby-build naming):
#   release 4.0.5        -> ["4.0.5", "4.0", "4"]
#   prerelease 4.1.0-rc1 -> ["4.1.0-rc1"]  (exact match only)
#   dev build            -> ["4.1-dev", "4.1-dev-20260712",
#                            "4.1.0dev-20260712-0123456789"]
#                           plus "ruby-dev" on the newest dev series
#
# Checksums are read from the .zip.sha256 files uploaded next to each
# zip; the zips themselves are never downloaded.  The "signed" flag is
# read from the S3 object metadata (signed=true) stamped by the
# uploading workflow.

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "aws-sdk-s3"
end

require 'aws-sdk-s3'
require 'json'

BUCKET = 'ftp.r-l.o'
PREFIX = 'pub/ruby/binaries/mswin64/'
INDEX_KEY = 'pub/ruby/binaries/index.json'
PLATFORM = 'x64-mswin64_140'

Build = Struct.new(
  :version, :channel, :tags, :platform, :url, :sha256, :size, :date,
  :commit, :signed, keyword_init: true
)

def sha256_for(bucket, key)
  body = bucket.object("#{key}.sha256").get.body.read
  sha = body.split.first
  raise "malformed checksum file for #{key}: #{body.inspect}" unless sha&.match?(/\A[0-9a-f]{64}\z/)
  sha
rescue Aws::S3::Errors::NoSuchKey
  raise "missing checksum file #{key}.sha256"
end

def signed?(bucket, key)
  bucket.object(key).metadata['signed'] == 'true'
end

def scan_builds(bucket)
  builds = []
  bucket.objects(prefix: PREFIX).each do |obj|
    next unless obj.key.end_with?('.zip')
    basename = File.basename(obj.key)
    common = {
      platform: PLATFORM,
      url: "https://cache.ruby-lang.org/#{obj.key}",
      sha256: sha256_for(bucket, obj.key),
      size: obj.size,
      signed: signed?(bucket, obj.key),
    }
    if obj.key.start_with?("#{PREFIX}dev/")
      m = basename.match(/\Aruby-(?<ver>\d+\.\d+\.\d+dev)-(?<date>\d{8})-(?<commit>\h{10})-#{PLATFORM}\.zip\z/o)
      raise "unrecognized dev package name: #{basename}" unless m
      series = m[:ver][/\A\d+\.\d+/]
      builds << Build.new(
        version: m[:ver],
        channel: 'dev',
        tags: [
          "#{series}-dev",
          "#{series}-dev-#{m[:date]}",
          "#{m[:ver]}-#{m[:date]}-#{m[:commit]}",
        ],
        date: m[:date].gsub(/\A(\d{4})(\d{2})(\d{2})\z/, '\1-\2-\3'),
        commit: m[:commit],
        **common,
      )
    else
      m = basename.match(/\Aruby-(?<ver>\d+\.\d+\.\d+(?:-[a-z0-9]+)?)-#{PLATFORM}\.zip\z/o)
      raise "unrecognized release package name: #{basename}" unless m
      ver = m[:ver]
      tags = [ver]
      unless ver.include?('-') # preview/rc resolve by exact match only
        series = ver[/\A\d+\.\d+/]
        tags << series << series[/\A\d+/]
      end
      builds << Build.new(
        version: ver,
        channel: 'release',
        tags: tags,
        date: obj.last_modified.utc.strftime('%Y-%m-%d'),
        commit: nil,
        **common,
      )
    end
  end
  builds
end

def tag_ruby_dev(builds)
  newest = builds.select { |b| b.channel == 'dev' }
                 .map { |b| b.version[/\A\d+\.\d+/] }
                 .max_by { |s| Gem::Version.new(s) }
  return unless newest
  builds.each do |b|
    b.tags << 'ruby-dev' if b.channel == 'dev' && b.version.start_with?("#{newest}.")
  end
end

def sort_builds(builds)
  # Normalize "4.1.0dev" and "3.4.0-rc1" into Gem::Version syntax.
  builds.sort_by { |b| [b.date, Gem::Version.new(b.version.sub(/dev\z/, '.dev').tr('-', '.'))] }.reverse
end

def create_index(bucket)
  builds = scan_builds(bucket)
  tag_ruby_dev(builds)
  index = {
    schema: 1,
    next: nil,
    builds: sort_builds(builds).map { |b| b.to_h.compact },
  }
  File.write('index.json', JSON.pretty_generate(index) + "\n")
end

def diff_index
  system(*%W(curl -fsS -o index.json~ https://cache.ruby-lang.org/#{INDEX_KEY}))
  return unless File.exist?('index.json~')
  system(*%w(git diff --no-index index.json~ index.json))
end

def upload_index(bucket)
  STDERR.puts "Upload #{INDEX_KEY}"
  bucket.object(INDEX_KEY).upload_file('index.json', content_type: 'application/json')
end

def purge_fastly
  system(*%W(curl -sS -X PURGE -H Fastly-Soft-Purge:1 https://cache.ruby-lang.org/#{INDEX_KEY}))
end

def update_binaries_index
  s3 = Aws::S3::Resource.new(region: 'us-east-1')
  bucket = s3.bucket(BUCKET)
  create_index(bucket)
  diff_index
  upload_index(bucket)
  purge_fastly
end

if __FILE__ == $0
  update_binaries_index
end
