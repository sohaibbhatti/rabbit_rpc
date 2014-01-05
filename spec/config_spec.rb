require 'rabbit_rpc'

describe RabbitRPC::Config do
  describe '.client_rpc_path' do
    it 'assumes the file to be present in the config folder by default' do
      RabbitRPC::Config.client_rpc_path.should == 'config/rabbit_rpc.yml'
    end

    it 'returns the configured value' do RabbitRPC::Config.client_rpc_path = 'foo/bar.yml'
      RabbitRPC::Config.client_rpc_path.should == 'foo/bar.yml'
    end
  end

  describe '.initialize!' do
    context 'with a valid YAML file' do
      before do
        RabbitRPC::Config.client_rpc_path = 'spec/support/rpc.yaml'
        RabbitRPC::Config.initialize!
      end

      it 'reads the client rpc file and initializes classes under the Client namespace' do
        %w[create read delete].each do |meth|
          RabbitRPC::Client::UserService::User.should respond_to meth
        end

        RabbitRPC::Client::UserService::Auth.should respond_to 'authorize'
      end

      it 'successfully encodes the messages with the proper arguments' do
        # Do not wait for response
        RabbitRPC::SynchronousConnection.any_instance.stub(:publish!).and_return(true)

        RabbitRPC::Message.should_receive(:new).with('AuthService.authorize', 'omg', 'this', 'works'). \
          and_call_original
        RabbitRPC::Client::UserService::Auth.authorize 'omg', 'this', 'works'
      end
    end

    it 'raises an exception if the address of the service is missing in the yml file' do
      RabbitRPC::Config.client_rpc_path = 'spec/support/rpc_no_address.yaml'
      expect { RabbitRPC::Config.initialize! }.to raise_error(RabbitRPC::InvalidFormatError)
    end

    it 'raises and exception if method definition is not decipherable' do
      RabbitRPC::Config.client_rpc_path = 'spec/support/rpc_invalid_structure.yaml'
      expect { RabbitRPC::Config.initialize! }.to raise_error(RabbitRPC::InvalidFormatError)
    end
  end
end
