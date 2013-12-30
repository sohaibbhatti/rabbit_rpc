require 'fluffy'

describe Fluffy::Logging do
  let(:random_class) do
    class RandomClass
      include Fluffy::Logging
    end
  end

  it 'grants the class and its objects the ability to log' do
    random_class.logger.should be_instance_of Logger
    random_class.new.logger.should be_instance_of Logger
  end
end
