##
# Result of a GCM multicast message request .
#

class SimpleGCM::MulticastResult

  ATTRIBUTES = [:success, :failure, :canonical_ids, :results, :multicast_id].freeze
  attr_accessor *ATTRIBUTES

  def initialize(args = {})
    @data = {}
    ATTRIBUTES.each do |attr|
      if (args.key?(attr))
        instance_variable_set("@#{attr}", args[attr])
      end
    end
  end

  def inspect
    ATTRIBUTES.inject({ }) do |h, attr|
      h[attr] = instance_variable_get("@#{attr}")
      h
    end
  end

  def to_json
    self.inspect.to_json
  end

end
