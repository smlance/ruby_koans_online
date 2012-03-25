require 'bundler'
Bundler.require
require './test'

run Sinatra::Application
