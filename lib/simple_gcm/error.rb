module SimpleGCM::Error
  class BaseError < StandardError
    attr_reader :response

    def initialize(ex, response = nil)
      @wrapped_exception = nil
      @response = response

      if ex.respond_to?(:backtrace)
        super(ex.message)
        @wrapped_exception = ex
      elsif ex.respond_to?(:each_key)
        super("GCM server responded with error #{ex[:error]} and status #{ex[:status]}")
        @response = ex
      else
        super(ex.to_s)
      end
    end

    def backtrace
      if @wrapped_exception
        @wrapped_exception.backtrace
      else
        super
      end
    end

    def inspect
      %(#<#{self.class}>)
    end
  end
  class MissingRegistration < BaseError; end
  class InvalidRegistration < BaseError; end
  class MismatchSenderId < BaseError; end
  class NotRegistered < BaseError; end
  class MessageTooBig < BaseError; end
  class AuthenticationError < BaseError; end
  class ServerUnavailable < BaseError; end
  class Unknown < BaseError; end
end
