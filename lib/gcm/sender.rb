class GCM::Sender
  BASE_ENDPOINT_URL = 'https://android.googleapis.com'
  SEND_PATH = '/gcm/send'

  attr_accessor :api_key, :connection

  def initialize(options)
    @api_key = options.delete(:api_key)
  end

  def send(message)
    http_parameters = { :registration_id => message.registration_id }
    message.data.each_pair do |k,v|
      http_parameters["data.#{k}"] = v.to_s
    end
    http_parameters[:collapse_key] = message.collapse_key if message.collapse_key
    http_parameters[:delay_while_idle] = "1" if message.delay_while_idle
    http_parameters[:time_to_live] = message.time_to_live if message.time_to_live
    response = connection.post SEND_PATH do |req|
      req.headers['Content-Type']  = 'text/plain'
      req.headers['Authorization'] = "key=#{api_key}"
      req.params = http_parameters
    end
    response.env[:gcm_response]
  end

  def connection
    @connection ||= ::Faraday.new(:url => BASE_ENDPOINT_URL) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  ::Faraday.default_adapter  # make requests with Net::HTTP
      faraday.use GCM::ResponseMiddleware
    end
  end
end