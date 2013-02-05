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
  response = Net::HTTP.get_response(URI.parse('http://mongo.cf104.dev.las01.vcsops.com/svc'))
  services = JSON.parse(response.body) 
  service_key = services.keys.select { |srv| srv =~ /mongodb/i }.first
  @service_info = services[service_key].first['credentials']
end

get_service_info
puts "Mongo configured at" 
puts " - host: #{@service_info['host']}" 
puts " - port: #{@service_info['port']}" 
puts " - user: #{@service_info['username']}" 
puts " - pass: #{@service_info['password']}"
puts " - name: #{@service_info['name']}"
puts " - db  : #{@service_info['db']}"

conn = Mongo::Connection.new(@service_info['host'], @service_info['port']).db(@service_info['db'])

auth = conn.authenticate(@service_info['username'], @service_info['password'])
puts "Auth returned: #{auth}"

testdata = conn.collection("testdata")
results = conn.collection("results")

puts "TestOptions: PutData = #{$put}, Verify = #{$verify}, GC = #{$gc}"

puts "Collections: #{conn.collection_names}";
puts "Rows:\n - testdata = #{testdata.count()}\n - results = #{results.count()}"

putdata(testdata, results) if $put
verifydata(testdata, results) if $verify
gcdata(testdata, results) if $gc

