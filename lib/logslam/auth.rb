require 'net/http'
require 'digest/sha1'
require 'base64'

module AUTH
  def self.authenticated?(username, password)
    url = URI.parse('http://example.com/some_auth_url')
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url.path)
    request.set_form_data({
      'username' => username,
      'passwordHash' => hash_password(password),
      'application' => 10
                          })
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      true if response.body.include?("authenticated=true")
    else
      false
    end
  rescue
    false
  end

  protected

  private

  def self.hash_password(password)
    Base64.encode64(Digest::SHA1.digest("#{password}{theSaltyGoodness}")).chomp
  end
end
