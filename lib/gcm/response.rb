class GCM::Response
  attr_accessor :message_id, :registration_id
  def inspect
    { message_id: message_id, registration_id: registration_id }
  end
  def to_s
    "#<#{self.class} #{inspect.to_s}>"
  end
end
