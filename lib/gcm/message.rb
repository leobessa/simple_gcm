class GCM::Message
  ATTRIBUTES = [:data, :collapse_key, :delay_while_idle, :time_to_live].freeze
  ATTRIBUTES.each do |attr|
    attr_accessor attr
  end

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