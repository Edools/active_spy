require 'hashie'

yml_path = Rails.root.join('config', 'active_spy.yml')
all_settings = YAML.load_file(yml_path)
env_settings = Hashie::Mash.new(all_settings[Rails.env])

ActiveSpy.configure do |config|
  config.name env_settings['name']
  config.host env_settings['host']
  config.port env_settings['port'].to_s

  config.event_host env_settings['event_host']
  config.event_port env_settings['event_port'].to_s
end
