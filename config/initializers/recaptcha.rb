Recaptcha.configure do |config|
  key_file = File.expand_path('~/.recaptcha_key').to_s

  # Create the file to put Recaptcha keys in
  unless File.exist?(key_file)
    file = File.open(key_file, 'w')
    file.write("REPLACE WITH PUBLIC KEY\n")
    file.write('REPLACE WITH PRIVATE KEY')
    file.close
  end

  config.site_key  = IO.readlines(key_file)[0]

  config.secret_key = IO.readlines(key_file)[1]

  config.api_server_url = 'v2'
end