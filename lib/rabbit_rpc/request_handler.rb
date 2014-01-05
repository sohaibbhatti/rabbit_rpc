module RabbitRPC
  class RequestHandler
    include Logging

    attr_reader :one_way

    def initialize(serialized_message)
      @message = Message.unpack serialized_message
    end

    def execute
      parser = MessageParser.new(@message)
      parser.parse

      @one_way = parser.one_way?

      logger.info "Received message #{@message}"

      Kernel.const_get(parser.service_name).send(parser.method_name, *@message['args'] )
    rescue ArgumentError => e
      log_exception(e)
      { ok: false, message: e.message }
    rescue Exception => e
      log_exception(e)
      exception_response
    end

    private

    # We do not want to return the actual exceptions back
    # TODO: Perhaps have this user defined?
    def exception_response
      { ok: false, message: 'Error processing request' }
    end

  end
end
