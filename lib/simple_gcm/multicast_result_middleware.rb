module SimpleGCM
  class MulticastResultMiddleware < ::Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        env[:gcm_multicast_result] = MulticastResult.new(MultiJson.load(env[:body],:symbolize_keys => true))
      when 400
        raise Error::BadRequest, response_values(env)
      when 401
        raise Error::AuthenticationError, response_values(env)
      when 500...600
        raise Error::ServerUnavailable, response_values(env)
      else
        raise Error::Unkown, response_values(env)
      end
    end

    def response_values(env)
      base = {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
    end

  end
end