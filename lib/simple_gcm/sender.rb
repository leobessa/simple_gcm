class SimpleGCM::Sender
  BASE_ENDPOINT_URL = 'https://android.googleapis.com'
  SEND_PATH = '/gcm/send'

  attr_accessor :api_key

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
    connection = options.fetch(:connection) { default_connection }.tap do |c|
      wrap_unicast(c)
      yield c if block_given?
    end
    response = connection.post SEND_PATH do |req|
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
    connection = options.fetch(:connection) { default_connection }.tap do |c|
      wrap_multicast(c)
      yield c if block_given?
    end
    response = connection.post SEND_PATH do |req|
      req.headers['Content-Type']  = 'application/json'
      req.headers['Authorization'] = "key=#{api_key}"
      req.body = http_body.to_json
    end
    response.env[:gcm_multicast_result]
  end

  def http_adapter
    @http_adapter ||= ::Faraday.default_adapter  # make requests with Net::HTTP
  end

  private

  def default_connection
    @default_connection ||= ::Faraday.new(:url => BASE_ENDPOINT_URL)
  end

  def wrap_unicast(conn)
    conn.tap  do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  http_adapter
      faraday.use SimpleGCM::ResultMiddleware
    end
  end

  def wrap_multicast(conn)
    conn.tap do |faraday|
      faraday.adapter  http_adapter
      faraday.use SimpleGCM::MulticastResultMiddleware
      faraday.response :json, :content_type => /\bjson$/
    end
  end

end