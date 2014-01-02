require 'fluffy'

describe Fluffy::SynchronousConnection do
  describe '#publish!' do
    let(:connection)      { Fluffy::SynchronousConnection.new('foo', 'bar', 'amqp:://localhost:5672') }
    let(:exchange)        { double 'exchange', publish: true }
    let(:message)         { Fluffy::Message.new 'User.create', 'bar' }
    let(:one_way_message) { Fluffy::Message.new 'User.one_way_create', 'bar' }
    let(:queue)           { double 'queue', subscribe: true }

    before do
      connection.stub(:exchange).and_return exchange
      connection.stub(:callback_queue).and_return queue
    end

    it 'sends a message to the relevant queue' do
      exchange.should_receive(:publish).with(
        message.pack,
        routing_key: 'foo',
        message_id:  anything(),
        reply_to:    'bar',
        auto_delete: false
      )
      connection.publish! message
    end

    context 'when a response is expected' do
      it 'subscribes to the callback queue to listen for a response' do
        queue.should_receive :subscribe
        connection.publish!(message)
      end
    end

    context 'when no response is expected' do
      it 'terminates' do
        queue.should_not_receive :subscribe
        connection.publish!(one_way_message)
      end
    end
  end
end
