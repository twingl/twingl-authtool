require 'yaml'
require 'oauth2'

# Load configuration
if File.exist? 'config.yml'
  config = YAML.load_file('config.yml')
else
  puts "config.yml not found. Please copy the example file and modify."
  exit
end

client = OAuth2::Client.new(
  config["client_id"],
  config["client_secret"],
  :site         => config["auth_site"],
  :token_method => :post
)

url = client.auth_code.authorize_url(:redirect_uri => config["redirect_uri"])

puts <<EOF
Please visit the following URL in your browser

#{url}

Paste the returned code and press enter:
EOF

code = gets.chomp # Remove the troublesome newline



# Obtain an access token from the now-approved auth token
puts "Getting access token...\n\n"
grant = client.auth_code.get_token(code, :redirect_uri => config["redirect_uri"])

puts <<EOF
Token:      #{grant.token}
Expires at: #{Time.at(grant.expires_at).iso8601}

Example Usage:
EOF



# Set up a client for reading from the API
client = OAuth2::Client.new(
  config["client_id"],
  config["client_secret"],
  :site => config["api_site"]
)
access_token = OAuth2::AccessToken.new(client, grant.token, :refresh_token => grant.refresh_token)

puts "GET api.twin.gl/v1/users/me\n\n"
puts access_token.get("/v1/users/me").body

puts "\n\n"

puts "GET api.twin.gl/v1/highlights?context=http://foo.bar\n\n"
puts access_token.get("/v1/highlights?context=http://foo.bar").body
