require 'aws-sdk-s3'
require 'fileutils'

task :snapshot do
  FileUtils.mkdir "ruby"
  Dir.chdir "ruby" do
    `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
    `ruby tool/make-snapshot -archname=snapshot . trunk`
  end
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/snapshot.tar.gz`
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/snapshot.tar.bz2`
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/snapshot.zip`
end

task "snapshot:stable" do
  FileUtils.mkdir "ruby"
  Dir.chdir "ruby" do
    `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
    `ruby tool/make-snapshot -archname=stable-snapshot . branches/ruby_2_5`
  end
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/stable-snapshot.tar.gz`
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/stable-snapshot.tar.bz2`
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/stable-snapshot.zip`
end
