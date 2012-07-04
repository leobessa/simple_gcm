require 'faraday'
require 'faraday_middleware'

module SimpleGCM
end

require_relative 'simple_gcm/message'
require_relative 'simple_gcm/error'
require_relative 'simple_gcm/result_middleware'
require_relative 'simple_gcm/result'
require_relative 'simple_gcm/multicast_result_middleware'
require_relative 'simple_gcm/multicast_result'
require_relative 'simple_gcm/sender'