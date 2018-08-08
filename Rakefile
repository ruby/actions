require 'aws-sdk-s3'
require 'fileutils'

task :snapshot do
  FileUtils.mkdir "pkg"
  `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
  `ruby tool/make-snapshot -archname=snapshot pkg trunk`
  upload_s3("snapshot")
  purge_fastly("snapshot")
end

task "snapshot:stable" do
  FileUtils.mkdir "pkg"
  `svn co http://svn.ruby-lang.org/repos/ruby/trunk/tool`
  `ruby tool/make-snapshot -archname=stable-snapshot pkg branches/ruby_2_5`
  upload_s3("stable-snapshot")
  purge_fastly("stable-snapshot")
end

def purge_fastly(name)
  pkgs = %w(.tar.gz .tar.bz2 .zip).map{|ext| "#{name}#{ext}"}

  pkgs.each do |pkg|
    `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/#{pkg}`
  end
end

def upload_s3(name)
  s3 = Aws::S3::Resource.new(region:'us-east-1')
  %w(.tar.gz .tar.bz2 .tar.xz .zip).each do |ext|
    obj = s3.bucket('ftp.r-l.o').object("pub/ruby/#{name}#{ext}")
    obj.upload_file("pkg/#{name}#{ext}")
  end
end
