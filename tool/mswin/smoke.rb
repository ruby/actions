# Run by mswin-build.yml with the packaged ruby, PATH restricted to
# System32.  Loads the extensions that need the bundled DLLs, completes a
# TLS handshake over loopback, where an OpenSSL miscompiled by MSVC 14.51
# for ARM64 crashes, and raises inside a fiber, which crashes when a
# coroutine does not switch the stack fields of the TEB.  Prints "ok"
# last.

require "openssl"
require "fiddle"
require "psych"
require "zlib"
require "socket"

key = OpenSSL::PKey::EC.generate("prime256v1")
cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 1
cert.subject = cert.issuer = OpenSSL::X509::Name.parse("/CN=localhost")
cert.public_key = key
cert.not_before = Time.now - 60
cert.not_after = Time.now + 3600
cert.sign(key, "SHA256")

server_ctx = OpenSSL::SSL::SSLContext.new
server_ctx.cert = cert
server_ctx.key = key
server = OpenSSL::SSL::SSLServer.new(TCPServer.new("127.0.0.1", 0), server_ctx)
port = server.to_io.addr[1]
th = Thread.new do
  s = server.accept
  s.puts s.gets.upcase
  s.close
end
client_ctx = OpenSSL::SSL::SSLContext.new
client_ctx.cert_store = OpenSSL::X509::Store.new.tap {|st| st.add_cert(cert)}
client_ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
client = OpenSSL::SSL::SSLSocket.new(TCPSocket.new("127.0.0.1", port), client_ctx)
client.hostname = "localhost"
client.connect
client.puts "tls"
reply = client.gets
client.close
th.join
abort "unexpected TLS reply: #{reply.inspect}" unless reply == "TLS\n"

message = begin
  Fiber.new { raise "in fiber" }.resume
rescue => e
  e.message
end
abort "unexpected fiber result: #{message.inspect}" unless message == "in fiber"

puts OpenSSL::OPENSSL_LIBRARY_VERSION, "ok"
