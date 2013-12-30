require 'logger'

module Fluffy

  module Logging

    def self.included(base)
      base.send :include, Methods
      base.extend Methods
    end

    module Methods
      def logger
        Fluffy::Logging.logger
      end

      # TODO: logger options
      def log_exception(ex)
        Fluffy:Logging.log_exception(ex)
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
