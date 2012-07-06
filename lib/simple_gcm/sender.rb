require 'json'

module SimpleGCM
  class Sender
    BASE_ENDPOINT_URL = 'https://android.googleapis.com'
    SEND_PATH = '/gcm/send'

    attr_accessor :api_key
    attr_writer :connection_maker

    def initialize(options)
      @api_key = options.delete(:api_key)
    end

    def send(options)
      registration_id = options.delete(:registration_id)
      message         = options.delete(:message)
      http_parameters = { :registration_id => registration_id }
      message.data.each_pair do |k,v|
        http_parameters["data.#{k}"] = v.to_s
      end
      http_parameters[:collapse_key] = message.collapse_key if message.collapse_key
      http_parameters[:delay_while_idle] = "1" if message.delay_while_idle
      http_parameters[:time_to_live] = message.time_to_live if message.time_to_live
      response = unicast_connection.post SEND_PATH do |req|
        req.headers['Authorization'] = "key=#{api_key}"
        req.params = http_parameters
      end
      response.env[:gcm_result]
    end

    def multicast(options)
      registration_ids = Array(options.delete(:to))
      message         = options.delete(:message)
      http_body = { :registration_ids => registration_ids }
      http_body[:data] = message.data if message.data
      http_body[:collapse_key] = message.collapse_key if message.collapse_key
      http_body[:delay_while_idle] = "1" if message.delay_while_idle
      http_body[:time_to_live] = message.time_to_live if message.time_to_live
      begin
        response = multicast_connection.post SEND_PATH do |req|
          req.headers['Content-Type']  = 'application/json'
          req.headers['Authorization'] = "key=#{api_key}"
          req.body = http_body.to_json
        end
        response.env[:gcm_multicast_result]
      rescue Error::ServerUnavailable => e
        failure_count = registration_ids.count
        results       = [{ :error => "Unavailable" }] * failure_count
        MulticastResult.new(:success => 0,:failure => failure_count,:canonical_ids => 0,:results => results)
      end
    end

    private

    def connection_maker
      @connection_maker ||= ::Faraday.public_method(:new)
    end

    def unicast_connection
      @unicast_connection ||= connection_maker.call(:url => BASE_ENDPOINT_URL).tap  do |c|
        c.request  :url_encoded             # form-encode POST params
        c.use SimpleGCM::ResultMiddleware
      end
    end

    def multicast_connection
      @multicast_connection ||= connection_maker.call(:url => BASE_ENDPOINT_URL).tap  do |c|
        c.use SimpleGCM::MulticastResultMiddleware
      end
    end

  end
end