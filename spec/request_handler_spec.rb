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
  let(:invalid_message) { Fluffy::Message.new 'Usvice.create' }
  let(:invalid_args_message) { Fluffy::Message.new 'UserService.create', 'args' }

  describe '#execute' do
    it 'succesfully executes the request method' do
      Fluffy::RequestHandler.new(message.pack).execute.should == 'woot'
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
