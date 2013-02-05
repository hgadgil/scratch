require 'rubygems'
require 'sinatra'
require 'json'

require 'couchrest'


def get_service_info(service_name)
  services = JSON.parse(ENV['VCAP_SERVICES'])
  service_key = services.keys.select { |srv| srv =~ /#{service_name}/i }.first
  services[service_key].first['credentials']
  
end

def get_couchdb_client()
  service = get_service_info("couchdb")
  host, port, user, pass = [service['host'], service['port'], service['username'], service['password']]

  @database = service['name']
  CouchRest.new("http://#{user}:#{pass}@#{host}:#{port}")
end


get '/' do
  res = ''
  ENV.each do |k, v|
    res << "#{k}: #{v}<br/>"
  end
  res
end

get '/svc' do
 ENV['VCAP_SERVICES']
end

get '/serviceinfo/:servicename' do
  service = get_service_info(params[:service_name])
  host, port, user, pass = [service['host'], service['port'], service['username'], service['password']]
  "<b>#{params[:service_name]} configured at</b><br>" \
  "host: #{host}<br>" \
  "port: #{port} <br>" \
  "username: #{user} <br>" \
  "password: #{pass} <br>" \
  "db name: #{service['name']}"
end

get '/get/:key' do
  result = "<H1>Getting from couchdb</H1> <h2>Key:#{params[:key]}</h2>" 
  begin
    client = get_couchdb_client
    result << "Got Client<br>"

    db = client.database!(@database)
    result << "Got DB Connection<br>"
    v = db.documents[params[:key]]

    result << "<b>#{params[:key]}</b> maps to #{v}"
  rescue => ex
    result << "Error: #{ex.to_s}"
  end

  result
end

get '/put/:key/:value' do
  result = "<H1>Saving to couchdb</H1> <h2>Key:#{params[:key]}</h2>" 

   begin
     client = get_couchdb_client
     result << "Got Client<br>"
     db = client.database(@database)
     result << "Got DB Connection<br>"
     id = db.save_doc(
        {params[:key] => params[:value]}
     )

     result << "<b>#{params[:key]}</b> = #{params[:value]}<br>Doc Id: <pre>#{id}</pre>"
   rescue => ex
     result << "Error: #{ex.to_s}"
   end

   result
end
