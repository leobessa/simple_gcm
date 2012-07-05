module SimpleGCM
  class MulticastResultMiddleware < ::Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        env[:gcm_multicast_result] = MulticastResult.new(JSON.parse(env[:body],:symbolize_names => true))
      else
        raise Error::ServerUnavailable, response_values(env)
      end
    end

    def response_values(env)
      base = {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
    end

  end
end