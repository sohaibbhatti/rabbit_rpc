require 'amqp'

#TODO: RabbitMQ connection options
module Fluffy
  class Connection
    PREFETCH_DEFAULT = 5

    include Logging

    attr_reader :queue_name, :uri, :opts, :prefetch

    def initialize(queue_name, uri, prefetch, opts = {})
      @queue_name = queue_name
      @uri        = uri
      @opts       = opts
      @prefetch   = prefetch || PREFETCH_DEFAULT
    end

    def listen!
      EventMachine.run do
        close_connection_on_interrupt
        subscribe_to_queue
      end
    end

    private

    def subscribe_to_queue
      queue.subscribe do |metadata, payload|

        EM.defer do
          request_handler  = RequestHandler.new(payload)
          response_message = request_handler.execute


          unless request_handler.one_way

            channel.default_exchange.publish(
              response_message.to_msgpack,
              routing_key:    metadata.reply_to,
              correlation_id: metadata.message_id,
              mandatory:      true
            )
          end

        end
      end
    end

    def connect!
      connection_params = ::AMQP::Client.parse_connection_uri @uri
      connection_params.merge! @opts
      logger.info 'Connecting to RabbitMQ'
      @connection ||= ::AMQP.connect connection_params
    end

    def channel
      logger.info 'Establishng connection with channel'
      @channel ||= ::AMQP::Channel.new connect!, prefetch: @prefetch
    end

    # Private - Establish connection with a RabbitMQ queue.
    # TODO: Queue options need to be provided
    def queue
      logger.info 'Connecting to queue'
      @queue ||= channel.queue @queue_name
    end

    def close_connection_on_interrupt
      %w[INT TERM].each do |interrupt_type|
        Signal.trap(interrupt_type) do
          logger.info 'Exiting'
          @connection.close do
            EventMachine.stop { exit }
          end
        end
      end
    end
  end
end
