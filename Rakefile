require 'aws-sdk-s3'
require 'fileutils'

task :snapshot do
  FileUtils.mkdir "ruby"
  `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
  `ruby tool/make-snapshot -archname=snapshot pkg trunk`
  purge_fastly("snapshot")
end

task "snapshot:stable" do
  FileUtils.mkdir "pkg"
  `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
  `ruby tool/make-snapshot -archname=stable-snapshot pkg branches/ruby_2_5`
  purge_fastly("stable-snapshot")
end

def purge_fastly(name)
  pkgs = %w(.tar.gz .tar.bz2 .zip).map{|ext| "#{name}#{ext}"}

  pkgs.each do |pkg|
    `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/#{pkg}`
  end
end
