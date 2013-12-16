require 'fluffy'

describe Fluffy::Message do

  describe '#pack' do
    it 'succesfully shifts the RPC method and its arguments to a single datastructure' do
      message = Fluffy::Message.new 'hello', 'argument_one', { optional: 'arguments' }
      message.should_receive(:serialize).with(method: 'hello', args: ['argument_one', { optional: 'arguments' }])
      puts message.pack
    end

    it 'succesfully handles the case of no arguments present' do
      message = Fluffy::Message.new 'hello'
      message.should_receive(:serialize).with(method: 'hello', args: [])
      puts message.pack
    end
  end
end

