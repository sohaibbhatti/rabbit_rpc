require 'fluffy'

describe Fluffy::RequestHandler do
  let!(:sample_service) do
    class UserService
      def self.create
        'woot'
      end
    end
  end
  let(:message)         { Fluffy::Message.new 'UserService.create' }
  let(:one_way_message) { Fluffy::Message.new 'UserService.one_way_create' }
  let(:invalid_message) { Fluffy::Message.new 'Usvice.create' }
  let(:invalid_args_message) { Fluffy::Message.new 'UserService.create', 'args' }

  describe '#execute' do
    it 'succesfully executes the request method' do
      Fluffy::RequestHandler.new(message.pack).execute.should == 'woot'
    end

    it 'identifies whether the method expects a response' do
      handler = Fluffy::RequestHandler.new(message.pack)
      handler.execute
      handler.one_way.should be_false

      handler = Fluffy::RequestHandler.new(one_way_message.pack)
      handler.execute
      handler.one_way.should be_true
    end

    it 'returns an exception message in the event of errors' do
      Fluffy::RequestHandler.new(invalid_message.pack).execute.should == {
        ok: false,
        message: 'Error processing request'
      }
    end

    it 'returns an error notifying an Argument error' do
      Fluffy::RequestHandler.new(invalid_args_message.pack).execute.should == {
        ok: false,
        message: 'wrong number of arguments (1 for 0)'
      }
    end
  end
end
