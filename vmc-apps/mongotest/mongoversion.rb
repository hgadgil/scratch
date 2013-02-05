require 'rubygems'
require 'json'
require 'uuidtools'

require 'mongo'
require 'net/http'
require 'optparse'

$put = $verify = $gc = false

OptionParser.new do |o|
 o.on('--put') { |b| $put = b }
 o.on('--verify') { |b| $verify = b }
 o.on('--gc') { |b| $gc = b }
 o.on('-h') { puts o; exit }
 o.parse!
end

def get_service_info
  response = Net::HTTP.get_response(URI.parse('http://x.vcap.me/svc'))
  services = JSON.parse(response.body)
  service_key = services.keys.select { |srv| srv =~ /mongolab-2.0/i }.first
  @service_info = services[service_key].first['credentials']
end

get_service_info
url = @service_info['MONGOLAB_URI']
puts "Mongo configured at"
puts " - URL: #{url}"

conn = Mongo::Connection.from_uri(url)
puts "Server Information: "
conn.server_info.each { |k, v|
  puts " - #{k} - #{v}"
}
