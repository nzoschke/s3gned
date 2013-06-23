#!/usr/bin/env ruby

require "aws-sdk"

ENV["AWS_ACCESS_KEY_ID"] && ENV["AWS_SECRET_ACCESS_KEY"] && ENV["BUCKET_NAME"] || abort("environment not set")

s3 = AWS::S3.new
bucket = s3.buckets[ENV["BUCKET_NAME"]]
bucket.objects.each do |obj|
  version, cipher = obj.key.split("/", 2)

  if cipher
    private_key = ENV["PRIVATE_KEY_#{version}"]
    decipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    decipher.decrypt
    decipher.key = [private_key].pack("H*")
    data = [cipher].pack("H*")

    begin
      decipher = decipher.update(data) + decipher.final
      next if decipher.ascii_only?
    rescue OpenSSL::Cipher::CipherError
    end
  end

  puts "#{obj.key}\t#{obj.versions.count} versions"
end