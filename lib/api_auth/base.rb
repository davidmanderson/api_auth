# api-auth is Ruby gem designed to be used both in your client and server
# HTTP-based applications. It implements the same authentication methods (HMAC) 
# used by Amazon Web Services.

# The gem will sign your requests on the client side and authenticate that 
# signature on the server side. It will even generate the 
# secret keys necessary for your clients to sign their requests.
module ApiAuth
  
  class << self
    
    include Helpers
    
    # Signs an HTTP request using the client's access id and secret key.
    # Returns the HTTP request object with the modified headers.
    #
    # request: The request can be a Net::HTTP, ActionController::Request, 
    # Curb (Curl::Easy) or a RestClient object.
    #
    # access_id: The public unique identifier for the client
    #
    # secret_key: assigned secret key that is known to both parties 
    def sign!(request, access_id, secret_key)
      nonce = "#{Time.new.to_i}:#{rand(36**8).to_s(36)}"
      headers = Headers.new(request)     
      headers.sign_header auth_header(request, nonce, access_id, secret_key)
    end
    
    # Determines if the request is authentic given the request and the client's
    # secret key. Returns true if the request is authentic and false otherwise.
    def authentic?(request, secret_key)
      return false if secret_key.nil?
      headers = Headers.new(request)
      if data = parse_auth_header(headers.authorization_header)
        return data[:secret_key] == hmac_signature(request, secret_key)
      end
      
      false
    end
    
    # Returns the access id from the request's authorization header
    def access_id(request)
      headers = Headers.new(request)
      if data = parse_auth_header(headers.authorization_header)
        return data[:access_id]
      end
      
      nil
    end
    
    # Generates a Base64 encoded, randomized secret key
    #
    # Store this key along with the access key that will be used for 
    # authenticating the client
    def generate_secret_key
      random_bytes = OpenSSL::Random.random_bytes(512)
      b64_encode(Digest::SHA2.new(512).digest(random_bytes))
    end
    
  private
  
    def hmac_signature(request, secret_key)
      headers = Headers.new(request)
      canonical_string = headers.canonical_string
      digest = OpenSSL::Digest::Digest.new('sha1')
      b64_encode(OpenSSL::HMAC.digest(digest, secret_key, canonical_string))
    end
    
    def auth_header(request, nonce, access_id, secret_key)
      "Authorization: MAC id=#{access_id},nonce=#{nonce},mac=#{hmac_signature(request, secret_key)}"      
    end
    
    def parse_auth_header(auth_header)
      matches = Regexp.new("Authorization: MAC id=(.*),nonce=(.*),mac=(.*)").match(auth_header)
      {:access_id => matches[1], :nonce => matches[2], :secret_key => matches[3]} if matches
    end
    
  end # class methods
  
end # ApiAuth
