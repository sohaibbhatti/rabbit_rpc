require 'yaml'
require 'active_support/inflector'

module Fluffy
  class InvalidFormatError < StandardError; end

  class Config
    @@service_address = {}

    class << self

      def client_rpc_path
        @@rpc_path ||= File.join 'config', 'fluffy_rpc.yml'
      end

      def client_rpc_path=(path)
        @@rpc_path = path
      end

      # Traverses through the RPC YAML file and creates RPC invocations
      # under the Fluffy::Client namespace.
      #
      # UserService:
      #   Authorization: auth
      #   Friend: list, delete
      #
      # Fluffy::Client::UserService::Friends.list
      # TODO: Abstract this logic into a seperate class
      def initialize!
        YAML.load_file(client_rpc_path).each do |service_name, class_definitions|
          unless class_definitions.is_a?(Hash) && class_definitions.keys.sort == %w[address methods]
            raise InvalidFormatError, "Error parsing the structure of the RPC YAML"
          end

          mdule        = Module.new
          service_name = "#{service_name}".classify

          ::Fluffy::Client.const_set service_name, mdule
          class_definitions.each do |param, value|
            if is_address?(param)
              @@service_address ||= {}
              @@service_address[service_name] = value
            elsif is_method_declaration?(param)
              populate_rpc(service_name, value)
            end
          end
        end
      end

      private

      def is_address?(key)
        key == 'address'
      end

      def is_method_declaration?(key)
        key == 'methods'
      end

      def populate_rpc(service_name, class_and_methods)
        if @@service_address[service_name].nil?
          raise InvalidFormatError, "The address declaration in the YAML file appears to be missing for #{service_name}"
        end

        class_and_methods.each do |klass_name, methods|
          klass_name = klass_name.classify

          klass = Class.new do
            methods.gsub(/\s+/, "").split(',').each do |method_name|
              define_singleton_method(method_name) do |*args|

                Fluffy::SynchronousConnection.new(
                  service_name,
                  "#{service_name}.callback",
                  @@service_address[service_name]).publish!(Fluffy::Message.new("#{klass_name}Service.#{method_name}", *args))
              end
            end
          end

          "Fluffy::Client::#{service_name}".constantize.const_set(klass_name, klass)
        end
      end

    end

  end
end
