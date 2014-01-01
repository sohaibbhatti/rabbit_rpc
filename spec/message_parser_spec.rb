require 'fluffy'

describe Fluffy::MessageParser do
  let(:message) { {'method' => 'UserService.create', 'args' => [1, 2, 3] } }
  let(:one_way) { {'method' => 'AuthService.one_way_delete', 'args' => [1, 2, 3] } }

  describe '#one_way?' do
    it 'determines if the method begins with the one_way prefix' do
      example_one = Fluffy::MessageParser.new(message)
      example_one.parse
      example_one.one_way?.should be_false

      example_two = Fluffy::MessageParser.new(one_way)
      example_two.parse
      example_two.one_way?.should be_true
    end

    context 'parser has not executed' do
      it 'determines if the method begins with the one_way prefix' do
        Fluffy::MessageParser.new(message).one_way?.should be_false
        Fluffy::MessageParser.new(one_way).one_way?.should be_true
      end
    end
  end

  describe '#parse' do
    it 'correctly identifies the name of the Service' do
      example_one = Fluffy::MessageParser.new(message)
      example_one.parse
      example_one.service_name.should == 'UserService'

      example_two = Fluffy::MessageParser.new(one_way)
      example_two.parse
      example_two.service_name.should == 'AuthService'
    end

    it 'correctly identifies the name of the method' do
      example_one = Fluffy::MessageParser.new(message)
      example_one.parse
      example_one.method_name.should == 'create'

      example_two = Fluffy::MessageParser.new(one_way)
      example_two.parse
      example_two.method_name.should == 'one_way_delete'
    end

    # Test case for message class and hash
    # Invalid format?
  end
end
