require 'rubygems'
require 'sinatra'
require 'about_arrays'

get '/' do
  file = File.new("about_arrays.rb", "r")
  counter = 0
  while (line = file.gets)
    puts "#{counter}: #{line}"
    counter = counter + 1
  end
  file.close
end

