module SimpleGCM
  class MulticastResultMiddleware < ::Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        env[:gcm_multicast_result] = MulticastResult.new(symbolize_keys(env[:body] || {}))
      else
        raise Error::ServerUnavailable, response_values(env)
      end
    end

    def response_values(env)
      base = {:status => env[:status], :headers => env[:response_headers], :body => env[:body]}
    end
    
    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    when Array then value.map{ |v| symbolize_keys(v) }
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

  end
end