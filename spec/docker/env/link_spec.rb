require 'spec_helper'

describe Docker::Env::Link do
  around(:each) do |example|
    env = ENV.to_h
    begin
      ENV.clear
      example.run
    ensure
      ENV.replace(env)
    end
  end

  describe 'find' do
    it do
      expect(Docker::Env::Link.find 'mongo', 27017, ["127.0.0.1:27017"]).to match_array(["127.0.0.1:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      expect(Docker::Env::Link.find 'mongo', 27017).to match_array(["10.0.0.1:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['REDIS_PORT_6379_TCP'] = 'tcp://10.0.0.3:6379'
      expect(Docker::Env::Link.find 'mongo', 27017).to match_array(["10.0.0.1:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['OTHER_SERVICE_PORT_27017_TCP'] = 'tcp://10.0.0.2:27017'
      expect(Docker::Env::Link.find 'mongo', 27017).to match_array(["10.0.0.1:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['OTHER_SERVICE_PORT_27017_TCP'] = 'tcp://10.0.0.2:27017'
      expect(Docker::Env::Link.find nil, 27017).to match_array(["10.0.0.1:27017","10.0.0.2:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['MONGO_PORT_28017_TCP'] = 'tcp://10.0.0.1:28017'
      expect(Docker::Env::Link.find 'mongo', 27017).to match_array(["10.0.0.1:27017"])
    end

    it do
      ENV['MONGO_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['MONGO_PORT_28017_TCP'] = 'tcp://10.0.0.1:28017'
      expect(Docker::Env::Link.find 'mongo').to match_array(["10.0.0.1:27017", "10.0.0.1:28017"])
    end

    it do
      ENV['MONGO_1_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['MONGO_2_PORT_27017_TCP'] = 'tcp://10.0.0.2:27017'
      expect(Docker::Env::Link.find 'mongo', 27017).to match_array(["10.0.0.1:27017", "10.0.0.2:27017"])
    end

    it do
      ENV['MONGO_1_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['MONGO_2_PORT_27017_TCP'] = 'tcp://10.0.0.2:27017'
      ENV['MONGO_1_PORT_28017_TCP'] = 'tcp://10.0.0.1:28017'
      ENV['MONGO_2_PORT_28017_TCP'] = 'tcp://10.0.0.2:28017'
      expect(Docker::Env::Link.find 'mongo').to match_array(["10.0.0.1:27017", "10.0.0.2:27017", "10.0.0.1:28017", "10.0.0.2:28017"])
    end

    it do
      ENV['MONGO_1_PORT_27017_TCP'] = 'tcp://10.0.0.1:27017'
      ENV['MONGO_2_PORT_27017_TCP'] = 'tcp://10.0.0.2:27017'
      ENV['MONGO_1_PORT_28017_TCP'] = 'tcp://10.0.0.1:28017'
      ENV['MONGO_2_PORT_28017_TCP'] = 'tcp://10.0.0.2:28017'
      ENV['REDIS_PORT_6379_TCP'] = 'tcp://10.0.0.3:6379'
      expect(Docker::Env::Link.find).to match_array(["10.0.0.1:27017", "10.0.0.2:27017", "10.0.0.1:28017", "10.0.0.2:28017", "10.0.0.3:6379"])
    end
  end
end
