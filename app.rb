require 'yaml'
require 'json'
require 'redis'
require 'twitter'
require 'faraday'

config = YAML.load_file('config.yml')
redis = Redis.new host: config['redis']['db_host'], port: config['redis']['port']
debug = ENV['debug']

tw_rest = Twitter::REST::Client.new do |tw_config|
  tw_config.consumer_key = config['twitter']['consumer_key']
  tw_config.consumer_secret = config['twitter']['consumer_secret']
  tw_config.access_token = config['twitter']['access_token']
  tw_config.access_token_secret = config['twitter']['access_token_secret']
end

tw_streaming = Twitter::Streaming::Client.new do |tw_config|
  tw_config.consumer_key = config['twitter']['consumer_key']
  tw_config.consumer_secret = config['twitter']['consumer_secret']
  tw_config.access_token = config['twitter']['access_token']
  tw_config.access_token_secret = config['twitter']['access_token_secret']
end

topics = ['MusicFM', 'Music FM', 'MusicBox']
puts '====='
tw_streaming.filter(track: topics.join(',')) do |object|
  user_status = redis.get object.user.id
  if object.text =~ /.*Music(?: (?:Box|FM)|Box|FM)から(?:プレイリスト|楽曲)『.*』をシェアしました。.*/
    song_name = object.text[/『(.*)』/, 1]
    res = Faraday.get(URI.encode("https://ws.audioscrobbler.com/2.0/?method=track.search&track=#{song_name}&api_key=#{config['last_fm']['api_key']}&format=json"))
    if res.success?
      song = JSON.parse res.body, {symbolize_names: true}
      if song[:results][:trackmatches][:track].length != 0
        artist_name = song[:results][:trackmatches][:track][0][:artist]
        redis.zincrby 'rank/artist', 1, artist_name
      end
      redis.zincrby 'rank/song', 1, song_name
    end
    if user_status == nil
      tw_rest.block(object.user.id)
      redis.set object.user.id, 'blocked'
      puts "#{object.user.name}(#{object.user.screen_name}, #{object.user.id})をブロックしました"
    end
  end
end
