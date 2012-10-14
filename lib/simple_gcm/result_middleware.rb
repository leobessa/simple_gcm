module SimpleGCM
  class ResultMiddleware < ::Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 200
        values = response_values(env)
        if values[:error]
          if Error.constants.include?(values[:error].to_sym)
            raise Error.const_get(values[:error]), values
          else
            raise Error::Unknown, values
          end
        else
          result = Result.new
          result.message_id = values[:id] if values[:id]
          result.registration_id = values[:registration_id] if values[:registration_id]
          env[:gcm_result] = result
        end
      when 401
        raise Error::AuthenticationError, response_values(env)
      when 500,503
        raise Error::ServerUnavailable, response_values(env)
      when 400...600
        raise Error::Unknown, response_values(env)
      end
    end

    def response_values(env)
      body = env[:body]
      base = {:status => env[:status], :headers => env[:response_headers], :body => body}
      response_body = Array(body.lines.map{ |l| Hash[l.scan(/(.*)=(.*)/)] }.inject(&:merge)).inject({}) do |m,(k,v)|
        m[k.downcase.to_sym] = v
        m
      end
      response_body.merge(base)
    end

  end
end