require 'fluffy'

describe Fluffy::Config do
  describe '.client_rpc_path' do
    it 'assumes the file to be present in the config folder by default' do
      Fluffy::Config.client_rpc_path.should == 'config/fluffy_rpc.yml'
    end

    it 'returns the configured value' do Fluffy::Config.client_rpc_path = 'foo/bar.yml'
      Fluffy::Config.client_rpc_path.should == 'foo/bar.yml'
    end
  end

  describe '.initialize!' do
    context 'with a valid YAML file' do
      before do
        Fluffy::Config.client_rpc_path = 'spec/support/rpc.yaml'
        Fluffy::Config.initialize!
      end

      it 'reads the client rpc file and initializes classes under the Client namespace' do
        %w[create read delete].each do |meth|
          Fluffy::Client::UserService::User.should respond_to meth
        end

        Fluffy::Client::UserService::Auth.should respond_to 'authorize'
      end

      it 'successfully encodes the messages with the proper arguments' do
        # Do not wait for response
        Fluffy::SynchronousConnection.any_instance.stub(:publish!).and_return(true)

        Fluffy::Message.should_receive(:new).with('AuthService.authorize', 'omg', 'this', 'works'). \
          and_call_original
        Fluffy::Client::UserService::Auth.authorize 'omg', 'this', 'works'
      end
    end

    it 'raises an exception if the address of the service is missing in the yml file' do
      Fluffy::Config.client_rpc_path = 'spec/support/rpc_no_address.yaml'
      expect { Fluffy::Config.initialize! }.to raise_error(Fluffy::InvalidFormatError)
    end

    it 'raises and exception if method definition is not decipherable' do
      Fluffy::Config.client_rpc_path = 'spec/support/rpc_invalid_structure.yaml'
      expect { Fluffy::Config.initialize! }.to raise_error(Fluffy::InvalidFormatError)
    end
  end
end
