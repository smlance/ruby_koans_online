require 'rubygems'
require 'sinatra'
require 'about_arrays'

get '/' do
  # IO.read("about_arrays.rb").gsub("\\s", "&nbsp;").gsub(/__/, "<input type='text' />").gsub(/\\n/, "<br />")
  file = IO.read("about_arrays.rb")

  # index of __def
  # index of __end + 5
  start  = file.index('  def')
  theend = file.index('  end') + 5

  file[start..theend]
end

