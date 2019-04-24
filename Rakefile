require 'aws-sdk-s3'
require 'fileutils'
require 'openssl'
require 'open-uri'
require 'pathname'

PKG_EXTS = %w(.tar.gz .tar.bz2 .tar.xz .zip)
EXT_NAMES = %w(.gz .bz2 .zip .xz)
DIRS = %w(1.0 1.1a 1.1b 1.1c 1.1d 1.2 1.3 1.4 1.6 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6)

task :snapshot do
  FileUtils.mkdir "pkg"
  `git clone --depth=1 https://github.com/ruby/ruby`
  `ruby ruby/tool/make-snapshot -archname=snapshot -srcdir=ruby pkg`
  upload_s3("snapshot")
  purge_fastly("snapshot")
end

task "snapshot:stable" do
  FileUtils.mkdir "pkg"
  `git clone --depth=1 --branch=ruby_2_6 https://github.com/ruby/ruby ruby_2_6`
  `ruby ruby_2_6/tool/make-snapshot -archname=stable-snapshot -srcdir=ruby_2_6 pkg`
  upload_s3("stable-snapshot")
  purge_fastly("stable-snapshot")
end

def purge_fastly(name)
  pkgs = PKG_EXTS.map{|ext| "#{name}#{ext}"}

  pkgs.each do |pkg|
    `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/#{pkg}`
  end
end

def upload_s3(name)
  s3 = Aws::S3::Resource.new(region:'us-east-1')
  PKG_EXTS.each do |ext|
    obj = s3.bucket('ftp.r-l.o').object("pub/ruby/#{name}#{ext}")
    obj.upload_file("pkg/#{name}#{ext}")
  end
end

task "update_index" do
  s3 = Aws::S3::Resource.new(region:'us-east-1')
  File.open('index.txt', 'w') do |f|
    f.puts "name\turl\tsha1\tsha256\tsha512"
    DIRS.each do |dir|
      s3.bucket('ftp.r-l.o').objects({prefix: "pub/ruby/#{dir}"}).each do |pkg|
        next unless EXT_NAMES.include?(Pathname(pkg.key).extname)
        next unless Pathname(pkg.key).basename.to_s =~ /ruby-/

        digests = %w(SHA1 SHA256 SHA512).map do |algm|
          digest = Object.const_get("OpenSSL::Digest::#{algm}").hexdigest(open("https://cache.ruby-lang.org/#{pkg.key}").read)
        end.join("\t")
        f.puts "#{Pathname(pkg.key).basename.to_s.gsub(/(\.tar\.gz|\.tar\.xz|\.tar\.bz2|\.zip)/, "")}\thttps://cache.ruby-lang.org/pub/ruby/#{dir}/#{Pathname(pkg.key).basename}\t#{digests}"
      end
    end
  end
  s3.bucket('ftp.r-l.o').object("pub/ruby/index.txt").upload_file("index.txt")
  `curl -X PURGE -H "Fastly-Soft-Purge:1" https://cache.ruby-lang.org/pub/ruby/index.txt`
  FileUtils.rm "index.txt"
end
