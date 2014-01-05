require "rabbit_rpc/version"
require "rabbit_rpc/logging"
require "rabbit_rpc/message"
require "rabbit_rpc/message_parser"
require "rabbit_rpc/config"
require "rabbit_rpc/client"
require "rabbit_rpc/synchronous_connection"
require "rabbit_rpc/request_handler"
require "rabbit_rpc/connection"

module RabbitRPC

  def self.logger
    RabbitRPC::Logging.logger
  end

end
