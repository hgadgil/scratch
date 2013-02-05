require 'rubygems'
require 'sinatra'
require 'json'

require 'mongo'



def get_service_info
  services = JSON.parse(ENV['VCAP_SERVICES']) 
  service_key = services.keys.select { |srv| srv =~ /mongodb/i }.first
  service = services[service_key].first['credentials']
  [service['host'], service['port'], service['user'], service['password']]
end

def get_client
  host, port, user, pass = get_service_info
  Mongo::Connection.new(host, port)
end

get '/' do
  host = ENV['VMC_APP_HOST']
  port = ENV['VMC_APP_PORT']

  output = "<h1>Hello from the Cloud! via: #{host}:#{port}</h1>"

  host, port, user, pass = get_service_info
  output << "<b>Mongo configured at</b><br>" \
  "host: #{host}<br>" \
  "port: #{port} <br>" \
  "username: #{user} <br>" \
  "password: #{pass}"

  output
end

get '/env' do
  res = ''
  ENV.each do |k, v|
    res << "#{k}: #{v}<br/>"
  end
  res
end


get '/svc' do
 ENV['VCAP_SERVICES']
end



get '/stressdata' do
  conn = get_client
  output ="<H1>Stress Data</h1><pre>"

  output << conn.database_names
  output << "\n\n"

  conn.database_info.each { |i| 
    output << i
  }

  output
end

get '/stressput' do
  mongo_client = get_client
end  

get '/stressverify' do

end
