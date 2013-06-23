# s3gned

S3gned is a simple service for configuring an S3 bucket, and generating 
unguessable and/or signed S3 URLs for a 3rd party to GET or PUT files in the 
bucket.

A common pattern is for a service to use AWS keys to generate temporary 
pre-signed URLs for a client. 

This pattern works best for clients that don't want to make a service call for every
operation on ephemeral data.


## Quick Start

# Create a bucket with public PUT/DELETE, and versioning, and a private key for signing sub paths

$ AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... BUCKET_NAME=s3gned bundle exec ./setup.rb
BUCKET_URL=http://s3gned.s3.amazonaws.com/
PRIVATE_KEY_1=ca3d6d3245b16a6dbf757523fe9a2e300b29e7942243f140b1477812f1f09105

# Append bucket and key in local environment file
$ !! >> .env

# Start the signing service and request a path

$ foreman start
$ curl -v http://localhost:5000/foo
/1/c41bdd43a8246ca7e21756e71c51a61c

# PUT, GET and DELETE a file to the prefix
$ curl -vX PUT -T Readme.md   http://s3gned.s3.amazonaws.com/1/c41bdd43a8246ca7e21756e71c51a61c
$ curl -vX GET                http://s3gned.s3.amazonaws.com/1/c41bdd43a8246ca7e21756e71c51a61c
$ curl -vX DELETE             http://s3gned.s3.amazonaws.com/1/c41bdd43a8246ca7e21756e71c51a61c
$ curl -vX GET                http://s3gned.s3.amazonaws.com/1/c41bdd43a8246ca7e21756e71c51a61c

# Moniture abuse by auditing paths

$ AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... BUCKET_NAME=s3gned foreman run audit

# Append private keys frequently

# Expire private keys at will