require "base64"
require "openssl"

input_path = ARGV.fetch(0)
output_path = ARGV.fetch(1)
password = ENV.fetch("IPA_DECRYPT_PASSWORD")

plain = File.binread(input_path)
salt = OpenSSL::Random.random_bytes(16)
iv = OpenSSL::Random.random_bytes(12)
key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 200_000, 32, OpenSSL::Digest::SHA256.new)

cipher = OpenSSL::Cipher.new("aes-256-gcm")
cipher.encrypt
cipher.key = key
cipher.iv = iv

ciphertext = cipher.update(plain) + cipher.final
tag = cipher.auth_tag

payload = {
  "version" => 1,
  "kdf" => "pbkdf2-hmac-sha256",
  "iterations" => 200_000,
  "cipher" => "aes-256-gcm",
  "salt" => Base64.strict_encode64(salt),
  "iv" => Base64.strict_encode64(iv),
  "tag" => Base64.strict_encode64(tag),
  "data" => Base64.strict_encode64(ciphertext)
}

require "json"
File.write(output_path, JSON.pretty_generate(payload))
