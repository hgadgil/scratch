require 'rubygems'
require 'sinatra'
require 'json'

get '/' do
  res = "<h1>Hello from the Cloud! </h1>" 
  res << "<table>"
  ENV.each do |k, v|
    res << "<tr><td><pre>#{k}</pre></td><td>#{v}</td></tr>\n"
  end
  res << "</table>"
  res
end

get '/svc' do
 ENV['VCAP_SERVICES']
end
