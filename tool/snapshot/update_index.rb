#!/usr/bin/env ruby
# frozen_string_literal: true

require 'aws-sdk-s3'
require 'digest'
require 'open-uri'
require 'pathname'

PKG_EXTS = %w(.tar.gz .tar.bz2 .tar.xz .zip).freeze
EXT_NAMES = %w(.gz .bz2 .zip .xz).freeze
DIRS = %w(1.0 1.1a 1.1b 1.1c 1.1d 1.2 1.3 1.4 1.6 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6).freeze

def create_index(bucket)
  cache_dir = Pathname(ENV['XDG_CACHE_HOME'] || "#{ENV['HOME']}/.cache") + 'snapshot'
  cache_dir.mkpath
  File.open('index.txt', 'w') do |f|
    f.puts "name\turl\tsha1\tsha256\tsha512"
    DIRS.each do |dir|
      bucket.objects({prefix: "pub/ruby/#{dir}"}).each do |pkg|
        path = Pathname(pkg.key)
        STDERR.puts "Processing #{path}"
        next unless EXT_NAMES.include?(path.extname)
        basename = path.basename.to_s
        name = basename.sub(/#{Regexp.union(PKG_EXTS)}\z/o, '')
        next unless name.start_with?('ruby-')
        uri = URI("https://cache.ruby-lang.org/#{pkg.key}")
        cache = cache_dir + basename
        if cache.exist?
          STDERR.puts 'Read from cache'
          body = cache.read
        else
          body = uri.read
          cache.write(body)
        end
        digests = %w(SHA1 SHA256 SHA512).map do |algm|
          Digest(algm).hexdigest(body)
        end.join("\t")
        f.puts "#{name}\t#{uri}\t#{digests}"
      end
    end
  end
end

def diff_index
  cmd = %W(curl -o index.txt~ https://cache.ruby-lang.org/pub/ruby/index.txt)
  STDERR.puts "Executing #{cmd}"
  system(*cmd)
  cmd = %W(git diff --no-index index.txt~ index.txt)
  STDERR.puts "Executing #{cmd}"
  system(*cmd)
end

def upload_index(bucket)
  STDERR.puts "Upload pub/ruby/index.txt"
  #bucket.object("pub/ruby/index.txt").upload_file("index.txt")
end

def purge_fastly
  cmd = %W(curl -X PURGE -H Fastly-Soft-Purge:1 https://cache.ruby-lang.org/pub/ruby/index.txt)
  STDERR.puts "Executing #{cmd}"
  #system(*cmd)
end

def update_index
  s3 = Aws::S3::Resource.new(region:'us-east-1')
  bucket = s3.bucket('ftp.r-l.o')
  create_index(bucket)
  diff_index
  upload_index(bucket)
  purge_fastly
end

if __FILE__ == $0
  update_index
end
