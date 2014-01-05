module RabbitRPC
  class MessageParserException; end

  class MessageParser
    attr_reader :service_name, :method_name

    # methods with the following prefix will not wait
    # for a response
    ONE_WAY_PREFIX = 'one_way'

    def initialize(message)
      @message = message
    end

    # Public: Extracts the Service name and method name
    #
    # Examples
    #
    #  "UserService.create"
    #  # => "UserService", "create"
    #
    # Returns nothing
    def parse
      method = @message.is_a?(RabbitRPC::Message) ? @message.method_name : @message['method']
      @service_name, @method_name = method.split('.')
    end

    # Public: Identifies whether a wait for a response is expected
    #
    # Returns a Boolean
    def one_way?
      parse if @method_name.nil?
      @method_name.start_with?(ONE_WAY_PREFIX)
    end
  end
end
