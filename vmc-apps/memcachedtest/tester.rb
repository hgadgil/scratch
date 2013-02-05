require 'rubygems'

require 'dalli'
require 'optparse'

$host = $port = $user = $pass = ""

OptionParser.new do |o|
 o.on('--host [HOST]') { |b| $host = b }
 o.on('--port [PORT]') { |b| $port = b }
 o.on('--user [USER]') { |b| $user = b }
 o.on('--pass [PASS]') { |b| $pass = b }
 o.on('-h') { puts o; exit }
 o.parse!
end

puts "Connecting to memcached: HOST:#{$host}, PORT: #{$port}, USER: #{$user}, PASS: #{$pass}"

client = Dalli::Client.new("#{$host}\:#{$port}", username: $user, password: $pass)

puts "Putting key = k, value = v"

client.set("k", "v")

puts "Get returned: #{client.get("k")}"

