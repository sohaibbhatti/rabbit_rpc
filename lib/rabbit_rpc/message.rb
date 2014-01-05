require 'msgpack'

module RabbitRPC
  class Message

    attr_reader :method_name, :args

    def initialize(method_name, *args)
      @method_name = method_name
      @args        = args
    end

    # Squeezes and serializes the RPC method name and arguments
    #
    # Returns the packed and serialized string
    def pack
      serialize(method: @method_name, args: @args)
    end

    # Unpacks a serialized message to a hash containing the method and
    # its args. This method needs to be modified if a serializer other
    # than MessagePack is to be used.
    #
    # Returns a Hash
    def self.unpack(message)
      MessagePack.unpack message
    end

    def self.generate_id
      SecureRandom.uuid
    end

    private

    # Private: Serialize the message. Currently using message pack. The
    # implementation can be changed in order to use some other serializer.
    #
    # Returns the serialized String
    def serialize(message)
      message.to_msgpack
    end
  end
end
