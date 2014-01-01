require "fluffy/version"
require "fluffy/logging"
require "fluffy/message"
require "fluffy/message_parser"
require "fluffy/config"
require "fluffy/client"
require "fluffy/synchronous_connection"

module Fluffy

  def self.logger
    Fluffy::Logging.logger
  end
  # Your code goes here...
end
