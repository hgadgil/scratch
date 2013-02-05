require 'rubygems'
require 'json'
require 'net/http'
require 'couchrest'


def get_service_info()
  response = Net::HTTP.get_response(URI.parse('http://couch.vcap.me/svc'))
  services = JSON.parse(response.body)
  service_key = services.keys.select { |srv| srv =~ /couchdb/i }.first
  @service_info = services[service_key].first['credentials']
  puts " - host: #{@service_info['host']}" 
  puts " - port: #{@service_info['port']}" 
  puts " - user: #{@service_info['username']}" 
  puts " - pass: #{@service_info['password']}"
  puts " - name: #{@service_info['name']}"  
end

def get(db, key)
  puts "Getting from couchdb"
  puts "Key:#{key}" 
  begin

    #v = db.get(key, :limit => 1)
    v = db.get("testentry")[key]

    puts  "#{key} maps to #{v}"
  rescue => ex
    puts  "Error: #{ex.to_s}"
  end

  v
end


def put(db, key, value)
  puts "Saving to couchdb"
  puts "Key:#{key}" 

   begin
     id = db.save_doc(
        {
           "_id" => "testentry",
           key => value
        }
     )

     puts "#{key} = #{value}"
     puts "Doc Id: #{id}"
   rescue => ex
     puts  "Error: #{ex.to_s}"
   end
end

get_service_info

@database = @service_info['name']
#
url = "http://#{@service_info['username']}:#{@service_info['password']}@#{@service_info['host']}:#{@service_info['port']}/"
puts "URL = #{url}"
client = CouchRest.new(url)
puts "Got Client"

db = client.database!(@database)
puts  "Got DB Connection"

put(db, "foo", "bar")
foo = get(db, "foo")
puts "foo = #{foo}"
