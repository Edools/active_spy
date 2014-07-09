require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActiveEvent::Configuration do

  Configuration = ActiveEvent::Configuration

  it 'should be able to set and return host' do
    Configuration.host '192.168.0.100'
    expect(Configuration.host).to eql('192.168.0.100')
  end

  it 'should be able to set and return port' do
    Configuration.port '8888'
    expect(Configuration.port).to eql('8888')
  end

  it 'should be able to return a hash of attributes' do
    ActiveEvent.configure do |config|
      config.host 'localhost'
      config.port '8888'
    end
    expect(Configuration.settings).to eql name: nil, hostname: 'localhost', port: '8888'
  end
end
