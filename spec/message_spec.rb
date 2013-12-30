require 'fluffy'

describe Fluffy::Message do

  describe '#pack' do
    it 'succesfully shifts the RPC method and its arguments to a single datastructure' do
      message = Fluffy::Message.new 'hello', 'argument_one', { optional: 'arguments' }
      message.should_receive(:serialize).with(method: 'hello', args: ['argument_one', { optional: 'arguments' }])
      message.pack
    end

    it 'succesfully handles the case of no arguments present' do
      message = Fluffy::Message.new 'hello'
      message.should_receive(:serialize).with(method: 'hello', args: [])
      message.pack
    end
  end

  describe '.unpack' do
    it 'successfully converts the serialized message into a readable datastructure' do
      message = Fluffy::Message.new 'hello', 'argument_one', { optional: 'arguments' }
      Fluffy::Message.unpack(message.pack).should == {
        'method' => 'hello',
        'args'  => ['argument_one', { 'optional' => 'arguments' }]
      }
    end
  end

  describe '.generate_id' do
    it 'generates random values' do
      Fluffy::Message.generate_id.should_not be_nil
      Fluffy::Message.generate_id.should_not == Fluffy::Message.generate_id
    end
  end
end

