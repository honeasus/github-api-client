#!/usr/bin/env ruby
$LOAD_PATH << './app/models/'
require 'net/http'
require 'uri'
require 'active_record'
require 'yaml'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'ruby.db'

Dir.glob('app/models/*.rb').each do |model|
  require model.scan(/\/([a-z]+).rb/).flatten.first
end

begin
  GitHub::User.delete_all
  $user = GitHub::User.create(YAML::load_file('config/secrets.yml')[:user])
  
rescue ActiveRecord::StatementInvalid
  puts 'Error: Did you run rake db:migrate?'
  puts 'Trying to do it for you...'
  system 'rake db:migrate'
  retry
  puts "Retrying after migration"
end

uri = URI.parse("http://github.com/api/v2/yaml/user/show/#{$user.login}")

Net::HTTP.get_print uri