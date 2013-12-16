require 'msgpack'

module Fluffy
  class Message

    attr_reader :method_name, :args

    def initialize(method_name, *args)
      @method_name = method_name
      @args        = args
    end

    # Squeezes and serializes the RPC method name and arguments 
    def pack
      serialize(method: @method_name, args: @args)
    end

    private

    # Private: Serialize the message. Currently using message pack. The
    # implementation can be changed in order to use some other serializer.
    #
    # Returns the serialized string
    def serialize(message)
      message.to_msgpack
    end
  end
end
