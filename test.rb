require 'rubygems'
require 'sinatra'
require File.expand_path(File.dirname(__FILE__) + '/koans/proxy')

def input
  params[:input] || []
end
get '/' do
  count = 0

  runnable_code = IO.read("koans/about_arrays.rb").gsub('/edgecase','/koans/edgecase').gsub(/ __/) do |match|
    x = input[count].to_s == "" ? " __" : " #{input[count]}"
    count = count + 1
    x
  end

  Proxy.proxy_eval(runnable_code)
  runnable_code
# 
#   inputs = IO.read("koans/about_arrays.rb").gsub("\\s", "&nbsp;").gsub( / __/) do |match|
#     x = input[count]
#     count = count + 1
#     "<input type='text' name='input[]' value='#{x}' />"
#   end.gsub(/\\n/, "<br />")
# 
#   "<form><input type='submit' />#{inputs}</form>"
end

