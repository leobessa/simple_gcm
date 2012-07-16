class SimpleGCM::Message
  ATTRIBUTES = [:data, :collapse_key, :delay_while_idle, :time_to_live].freeze
  attr_accessor *ATTRIBUTES

  def initialize(args = {})
    ATTRIBUTES.each do |attr|
      if (args.key?(attr))
        instance_variable_set("@#{attr}", args[attr])
      end
    end
    @data ||= {}
  end

  def inspect
    ATTRIBUTES.inject({ }) do |h, attr|
      h[attr] = instance_variable_get("@#{attr}")
      h
    end
  end

  def to_json
    MultiJson.dump(self.inspect)
  end
end