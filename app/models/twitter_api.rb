class TwitterApi < ApplicationRecord
  
  TWITTER_API_DOMAIN          = "https://api.twitter.com"
  TWITTER_CREATE_DM_ENDPOINT  = "#{TWITTER_API_DOMAIN}/1.1/direct_messages/events/new.json"
  TWITTER_SIGNATURE_METHOD    = "HMAC-SHA1"
  TWITTER_OAUTH_VERSION       = "1.0"
  TWITTER_CONSUMER_KEY        = ENV.fetch("TWITTER_CONSUMER_KEY")
  TWITTER_CONSUMER_SECRET     = ENV.fetch("TWITTER_SECRET_KEY")
  TWITTER_ACCESS_TOKEN        = ENV.fetch("TWITTER_ACCESS_TOKEN")
  TWITTER_ACCESS_TOKEN_SECRET = ENV.fetch("TWITTER_ACCESS_TOKEN_SECRET")
  
  def initialize(user_id, text)
    @user_id = user_id
    @text = text
  end

  def call
    uri = URI.parse(TWITTER_CREATE_DM_ENDPOINT)

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = JSON.generate(request_body_hash)

    request["Authorization"] = authorization_value

    options = { use_ssl: true }

    response = Net::HTTP.start(uri.hostname, uri.port, options) do |http|
      http.request(request)
    end
    
    if response.is_a?(Net::HTTPSuccess)
      return true
    else
      return false
    end
  end

  private
  def request_body_hash
    {
      event: {
        type: "message_create",
        message_create: {
          target: { recipient_id: @user_id },
          message_data: { text: @text }
        }
      }
    }
  end

  def authorization_value
    authorization_params = signature_params.merge(
      oauth_signature: generate_signature("POST", TWITTER_CREATE_DM_ENDPOINT)
    )
    return "OAuth " + authorization_params.sort.to_h.map{|k, v| "#{k}=\"#{v}\"" }.join(",")
  end

  def signature_params
    @signature_params ||= {
      oauth_consumer_key: TWITTER_CONSUMER_KEY,
      oauth_nonce: SecureRandom.uuid,
      oauth_signature_method: TWITTER_SIGNATURE_METHOD,
      oauth_timestamp: Time.zone.now.to_i,
      oauth_token: TWITTER_ACCESS_TOKEN,
      oauth_version: TWITTER_OAUTH_VERSION
    }
  end

  def oauth_values
    values = signature_params.sort.to_h.map {|k, v| "#{k}=#{v}" }.join("&")
    ERB::Util.url_encode(values)
  end

  def generate_signature(method, url)
    signature_data = [method, ERB::Util.url_encode(url), oauth_values].join("&")
    signature_key = "#{ERB::Util.url_encode(TWITTER_CONSUMER_SECRET)}&#{ERB::Util.url_encode(TWITTER_ACCESS_TOKEN_SECRET)}"
    signature_binary = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, signature_key, signature_data)
    ERB::Util.url_encode(Base64.strict_encode64(signature_binary))
  end
end
