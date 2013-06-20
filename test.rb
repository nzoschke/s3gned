#!/usr/bin/env ruby

require           "rack/test"
require           "test/unit"
require_relative  "api"

ENV["RACK_ENV"] = "test"

class SignerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def teardown
    ENV.delete_if { |k,v| k =~ /^PRIVATE_KEY/ }
  end

  def test_get
    ENV["PRIVATE_KEY_1"] = "e7562b50828a9764ba6887069e51f131c26c5c204332004c20ca02819bcb87e7"

    get "foo"
    assert_equal 200, last_response.status
    assert_equal "/1/b57861f5953cb572ae4d233c076ee586", last_response.body
  end

  def test_get_with_rotated_key
    ENV["PRIVATE_KEY_1"] = "e7562b50828a9764ba6887069e51f131c26c5c204332004c20ca02819bcb87e7"
    ENV["PRIVATE_KEY_2"] = "c607769a2030d26c1bf7cffcd48e6c384f9848aacab9d337d43d52df3c09e978"

    get "foo"
    assert_equal 200, last_response.status
    assert_equal "/2/a460b0f0458916944a9e74b91fde0311", last_response.body
  end

  def test_get_with_missing_key
    get "foo"
    assert_equal 501, last_response.status
  end
end

class CipherTest < Test::Unit::TestCase
  def test_cipher_deciper
    # generate hex encoded key
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    key = cipher.random_key.unpack("H*")[0]
    assert key =~ /[0-9a-f]+/

    # encrypt data with key
    cipher.encrypt
    cipher.key = [key].pack("H*")
    cipher = cipher.update("foo") + cipher.final
    data = cipher.unpack("H*")[0]

    # decrypt data with key
    decipher  = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    decipher.key = [key].pack("H*")
    decipher = decipher.update([data].pack("H*")) + decipher.final

    assert_equal "foo", decipher
  end
end
