require 'yaml'
require 'redis'

config = YAML.load_file('config.yml')
redis = Redis.new host: config['redis']['db_host'], port: config['redis']['port']

namespace :redis do
  desc 'Database Migration'
  task :migrate do
    redis.keys.each do |k|
      next if k =~ /blocked|rank\/.*/

      redis.sadd 'blocked', k
      redis.del k
    end
    puts 'Database Migration Success!!'
  end
end
