require 'yaml'
require 'json'
require 'redis'
require 'twitter'

config = YAML.load_file("config.yml")
redis = Redis.new host: config['redis']['db_host'], port: config['redis']['port']
debug = ENV['debug']

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

topics = ['MusicFM', 'Music FM', 'MusicBox']
puts "====="
tw_streaming.filter(track: topics.join(',')) do |object|
  user_status = redis.get object.user.id
  if object.text =~ /.*Music(?: (?:Box|FM)|Box|FM)から(?:プレイリスト|楽曲)『.*』をシェアしました。.*/
    tw_rest.block(object.user.id)
    redis.set object.user.id, 'blocked'
    # File.open('data/blocking.csv', 'a') do |f|
    #   f.puts(object.user.id)
    # end
    puts "#{object.user.name}(#{object.user.screen_name}, #{object.user.id})をブロックしました"
  end
end
