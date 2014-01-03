require 'bunny'
require 'active_support/core_ext/object/try'

#TODO: Implement callback queue timeout
#TODO: RabbitMQ connection options
module Fluffy
  # Connects to RabbitMQ for blocking RPC calls.
  # Wait for a response when querying other services
  class SynchronousConnection
    DEFAULT_HEARTBEAT = 30

    include Logging

    # RabbitMQ related info
    attr_reader :queue_name, :callback_queue_name, :rabbit_mq_url, :heartbeat

    # Message unique identifier and resposne
    attr_reader :message_id, :response

    def initialize(queue_name, callback_queue_name, rabbit_mq_url, heart_beat = nil)
      @queue_name          = queue_name
      @callback_queue_name = callback_queue_name
      @rabbit_mq_url       = rabbit_mq_url
      @heartbeat           = heart_beat || DEFAULT_HEARTBEAT

      @message_id          = Message.generate_id
    end

    def publish!(unpacked_message)
      connect!

      send_request(unpacked_message.pack)

      if wait_for_response?(unpacked_message)
        callback_queue.subscribe(block: true, ack: true) do |delivery_info, properties, payload|
          if message_id == properties.try(:[],:correlation_id)
            @channel.acknowledge(delivery_info.delivery_tag, false)
            @response = Message.unpack payload

            logger.info "Received message #{@response}"
            delivery_info.consumer.cancel
          end
        end

        return @response
      end

      return response
    end

    private

    def connect!
      @connection = Bunny.new(@rabbit_mq_url, heartbeat: @heartbeat).start
      @channel    = @connection.create_channel
    end

    def callback_queue
      @channel.queue(@callback_queue_name, auto_delete: false)
    end

    def exchange
      @exchange ||= @channel.default_exchange
    end

    def send_request(message)
      exchange.publish(
        message,
        routing_key: @queue_name,
        message_id:  @message_id,
        reply_to:    @callback_queue_name,
        auto_delete: false
      )
    end

    def wait_for_response?(message)
      !MessageParser.new(message).one_way?
    end

  end
end
