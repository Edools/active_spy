require 'hashie'

yml_path = Rails.root.join('config', 'active_spy.yml')
if File.exists?(yml_path)
  all_settings = YAML.load(ERB.new(File.read(yml_path)).result)
  env_settings = Hashie::Mash.new(all_settings[Rails.env])
else
  # TODO: Add a warning here
  env_settings = {}
end

ActiveSpy.configure do |config|
  config.name env_settings['name']
  config.host env_settings['host']
  config.port env_settings['port'].to_s

  config.event_host env_settings['event_host']
  config.event_port env_settings['event_port'].to_s
  config.event_verify_ssl env_settings['event_verify_ssl']
end
