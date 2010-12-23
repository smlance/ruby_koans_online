require 'rubygems'
require 'sinatra'

get '/' do
  asdf = 5
  eval "puts #{params['something']}"
end

