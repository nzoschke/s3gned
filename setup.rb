#!/usr/bin/env ruby

require "aws-sdk"
require "openssl"

ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"] && ENV["BUCKET_NAME"] || abort("environment not set")

# Generate a random private key
cipher  = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
key     = cipher.random_key.unpack("H*")[0]

# Create an S3 bucket with public read/write and versioning
s3 = AWS::S3.new
bucket = s3.buckets[ENV["BUCKET_NAME"]]
bucket.delete if bucket.exists?

bucket = s3.buckets.create(ENV["BUCKET_NAME"], acl: :public_read_write)
bucket.enable_versioning

# export environment
puts "BUCKET_URL=#{bucket.url}"
puts "PRIVATE_KEY_1=#{key}"