##
# Result of a GCM message request that returned HTTP status code 200.
#
# There are cases when a request is accept and the message successfully
# created, but GCM has a canonical registration id for that device. In this
# case, the server should update the registration id to avoid rejected requests
# in the future.

class GCM::Result
  attr_accessor :message_id, :registration_id
  def inspect
    { message_id: message_id, registration_id: registration_id }
  end
  def to_s
    "#<#{self.class} #{inspect.to_s}>"
  end
end
