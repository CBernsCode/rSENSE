# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
require 'securerandom'

key_file = File.expand_path('~/.rails_key').to_s
unless File.exist?(key_file)
  kk = File.open(key_file, 'wb')
  6.times do
    kk.write(SecureRandom.urlsafe_base64)
  end
  kk.close
end

secret_key = File.open(key_file).read
Rsense::Application.config.secret_token = secret_key
Rsense::Application.config.secret_key_base = secret_key + 'aE'
