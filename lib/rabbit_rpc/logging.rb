require 'logger'

module RabbitRPC

  module Logging

    def self.included(base)
      base.send :include, Methods
      base.extend Methods
    end

    module Methods
      def logger
        RabbitRPC::Logging.logger
      end

      # TODO: logger options
      def log_exception(ex)
        RabbitRPC::Logging.log_exception(ex)
      end
    end

    def self.logger(target = $stdout)
      @logger ||= Logger.new(target)
    end

    def self.log_exception(ex)
      logger.error ('Message: ' + ex.message)
      logger.error (['backtrace:'] + ex.backtrace).join("\n")
    end
  end
end
