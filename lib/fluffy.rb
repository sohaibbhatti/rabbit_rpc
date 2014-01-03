require "fluffy/version"
require "fluffy/logging"
require "fluffy/message"
require "fluffy/message_parser"
require "fluffy/config"
require "fluffy/client"
require "fluffy/synchronous_connection"
require "fluffy/request_handler"
require "fluffy/connection"

module Fluffy

  def self.logger
    Fluffy::Logging.logger
  end

end
