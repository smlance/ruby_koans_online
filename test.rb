require 'rubygems'
require 'sinatra'
require 'timeout'
require File.expand_path(File.dirname(__FILE__) + '/string')
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")
ARRAY_ORIGINAL     = IO.read("koans/about_arrays.rb").remove_require_lines

def input
  params[:input] || []
end

get '/' do
  count = 0

  runnable_code = ARRAY_ORIGINAL.gsub(/__/) do |match|
    x = input[count].to_s == "" ? "__" : " #{input[count]}"
    count = count + 1
    x
  end
  unique_id = rand(10000)
  runnable_code = "
  require 'timeout'
  require 'test/unit/assertions'
  RESULTS = {:error => '', :failures => [], :pass_count => 0}
  $SAFE = 3
    begin
      Timeout.timeout(2) {
        module KoanArena
          module UniqueRun#{unique_id}
            #{::EDGECASE_CODE}
            #{::EDGECASE_OVERRIDES}
            #{runnable_code}
            path = EdgeCase::ThePath.new
            path.online_walk
            RESULTS[:pass_count] = path.sensei.pass_count
            RESULTS[:failures] = path.sensei.failures
          end
        end
        KoanArena.send(:remove_const, :UniqueRun#{unique_id})
      }
    rescue SecurityError => se
      RESULTS[:error] = \"What do you think you're doing, Dave? \" + se.message + se.backtrace.join('<br/>')
    rescue TimeoutError => te
      RESULTS[:error] = 'Do you have an infinite loop?'
    rescue StandardError => e
      RESULTS[:error] = ['standarderror', e.message, e.backtrace, e.inspect].flatten.join('<br/>')
    end
    RESULTS
  "
  results = Thread.new { eval runnable_code, TOPLEVEL_BINDING }.value

  pass_count = results[:pass_count]
  failures = results[:failures]
  inputs = ARRAY_ORIGINAL.
    gsub("\s", "&nbsp;").
    swap_input_fields(input, pass_count, failures.map{|f| "#{f.message} #{f.backtrace} #{f.inspect}"})

  page = "<form>
  <div style='position: absolute; height: 100%; width: 60%; overflow: auto;'>
     #{inputs}
  </div>
  <div style='position: absolute; right: 0px; width: 38%;'>
    <input type='submit' value='Meditate'/><br/>
    Results
    #{pass_count}<br/>
    #{failures.join('<br/>')}
    #{failures.count}
    #{results[:error]}
  </div>
  </form>
  <pre style='position:absolute;top:500px'>
  </pre>
  "
  page
end

