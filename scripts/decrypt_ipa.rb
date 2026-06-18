require "base64"
require "json"
require "openssl"

input_path = ARGV.fetch(0)
output_path = ARGV.fetch(1)
password = ENV.fetch("IPA_DECRYPT_PASSWORD")

payload = JSON.parse(File.read(input_path))
salt = Base64.decode64(payload.fetch("salt"))
iv = Base64.decode64(payload.fetch("iv"))
tag = Base64.decode64(payload.fetch("tag"))
ciphertext = Base64.decode64(payload.fetch("data"))
iterations = Integer(payload.fetch("iterations"))

key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, 32, OpenSSL::Digest::SHA256.new)

cipher = OpenSSL::Cipher.new("aes-256-gcm")
cipher.decrypt
cipher.key = key
cipher.iv = iv
cipher.auth_tag = tag

plain = cipher.update(ciphertext) + cipher.final
File.binwrite(output_path, plain)
