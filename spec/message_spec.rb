require 'rabbit_rpc'

describe RabbitRPC::Message do

  describe '#pack' do
    it 'succesfully shifts the RPC method and its arguments to a single datastructure' do
      message = RabbitRPC::Message.new 'hello', 'argument_one', { optional: 'arguments' }
      message.should_receive(:serialize).with(method: 'hello', args: ['argument_one', { optional: 'arguments' }])
      message.pack
    end

    it 'succesfully handles the case of no arguments present' do
      message = RabbitRPC::Message.new 'hello'
      message.should_receive(:serialize).with(method: 'hello', args: [])
      message.pack
    end
  end

  describe '.unpack' do
    it 'successfully converts the serialized message into a readable datastructure' do
      message = RabbitRPC::Message.new 'hello', 'argument_one', { optional: 'arguments' }
      RabbitRPC::Message.unpack(message.pack).should == {
        'method' => 'hello',
        'args'  => ['argument_one', { 'optional' => 'arguments' }]
      }
    end
  end

  describe '.generate_id' do
    it 'generates random values' do
      RabbitRPC::Message.generate_id.should_not be_nil
      RabbitRPC::Message.generate_id.should_not == RabbitRPC::Message.generate_id
    end
  end
end

