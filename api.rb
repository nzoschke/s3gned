#!/usr/bin/ruby

require "openssl"
require "sinatra"

get "/:data" do
  # read hex encoded private keys from ENV, and select the latest version
  versions = ENV.keys.map { |v| v.scan(/PRIVATE_KEY_([0-9]+)/) }.flatten
  halt(501) if versions.empty?

  version     = versions.sort.last
  private_key = ENV["PRIVATE_KEY_#{version}"]

  # encrypt the data with private key
  cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
  cipher.encrypt
  cipher.key = [private_key].pack("H*")
  cipher = cipher.update(params[:data]) + cipher.final

  # return private key version and hex encoded encrypted data
  "/#{version}/#{cipher.unpack("H*")[0]}"
end