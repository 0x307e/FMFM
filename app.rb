require 'yaml'
require 'json'
require 'twitter'

config = YAML.load_file("config.yml")

tw_rest = Twitter::REST::Client.new do |tw_config|
  tw_config.consumer_key = config['consumer_key']
  tw_config.consumer_secret = config['consumer_secret']
  tw_config.access_token = config['access_token']
  tw_config.access_token_secret = config['access_token_secret']
end

tw_streaming = Twitter::Streaming::Client.new do |tw_config|
  tw_config.consumer_key = config['consumer_key']
  tw_config.consumer_secret = config['consumer_secret']
  tw_config.access_token = config['access_token']
  tw_config.access_token_secret = config['access_token_secret']
end

topics = ['Music FMから楽曲', 'タップして聴きましょう。']
tw_streaming.filter(track: topics.join(',')) do |object|
  if object.text =~ /Music ?FMから楽曲『.*』をシェアしました。タップして聴きましょう。/
    tw_rest.block(object.id_str)
    p "#{object.user.name}(#{object.user.screen_name}, #{object.user.id_str})をブロックしました"
    p object.text
    p "="
  end
end
