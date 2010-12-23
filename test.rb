require 'rubygems'
require 'sinatra'

get '/' do
  eval "'hello'"
end

