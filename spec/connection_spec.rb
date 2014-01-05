require 'rabbit_rpc'
require 'evented-spec'

describe RabbitRPC::Connection do
  include EventedSpec::EMSpec
  let(:connection) { RabbitRPC::Connection.new('UserService', 'amqp://localhost:5672', 5) }
  let(:sync_connection) { RabbitRPC::SynchronousConnection.new('UserService', 'UserService.callback', 'amqp://localhost:5672') }
  let(:exchange) { double 'exchange', publish: true }

  it 'connects to the the specified rabbitMQ queue' do
    em do
      ::AMQP::Channel.any_instance.should_receive(:queue).with('UserService').and_call_original
      connection.listen!
      done(0.5)
    end
  end

  it 'attempts to execute received messages' do
    RabbitRPC::SynchronousConnection.new('UserService', 'UserService.callback', 'amqp://localhost:5672').publish!(RabbitRPC::Message.new('User.one_way_create'))

    em do
      RabbitRPC::RequestHandler.should_receive(:new).at_least(1).times.with(RabbitRPC::Message.new('User.one_way_create').pack).and_call_original
      connection.listen!
      done(0.5)
    end
  end

  context 'when the client expects a response' do

    it 'sends a response to the callback queue' do
      RabbitRPC::Message.stub(:generate_id).and_return 'omg'
      ::AMQP::Channel.any_instance.stub(:default_exchange).and_return exchange

      send_message_expecting_response

      em do
        exchange.should_receive(:publish).with(anything(), routing_key: 'UserService.callback', correlation_id: 'omg', mandatory: true)
        connection.listen!
        done(0.5)
      end
    end
  end

  context 'when the client does not expect a response' do
    it 'does not send a response to the callback queue' do
      RabbitRPC::Message.stub(:generate_id).and_return 'omg'
      ::AMQP::Channel.any_instance.stub(:default_exchange).and_return exchange

      send_one_way_message

      em do
        exchange.should_not_receive(:publish).with(anything(), routing_key: 'UserService.callback', correlation_id: 'omg', mandatory: true)
        connection.listen!
        done(0.5)
      end
    end
  end

  # Disables the client blocking wait for receiving the message
  # on the callback queue
  def send_message_expecting_response
    message = RabbitRPC::Message.new('User.create')
    sync_connection.stub(:wait_for_response?).and_return(false)
    sync_connection.publish! message
  end

  def send_one_way_message
    message = RabbitRPC::Message.new('User.one_way_create')
    sync_connection.publish! message
  end
end
