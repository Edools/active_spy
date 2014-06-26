require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveEvent::Configuration do

  Configuration = ActiveEvent::Configuration

  it 'set and return host' do
    Configuration.host '192.168.0.100'
    expect(Configuration.host).to eql('192.168.0.100')
  end

  it 'set and return port' do
    Configuration.port '8888'
    expect(Configuration.port).to eql('8888')
  end

  it 'return a hash of attributes' do
    Configuration.instance_eval do
      host 'localhost'
      port '8888'
    end
    expect(Configuration.settings).to eql host: 'localhost', port: '8888'
  end
end
