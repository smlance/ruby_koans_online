require 'rubygems'
require 'sinatra'
require 'timeout'
require File.expand_path(File.dirname(__FILE__) + '/string')
EDGECASE_CODE      = IO.read("koans/edgecase.rb").split(/END\s?\{/).first
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
  module RunResults
    SENSEI = nil
    ERRORS = ""
  end
  unique_id = rand(10000)
  runnable_code = "
  $SAFE = 3
    begin
      Timeout::timeout(2) {
        module KoanArena
          module UniqueRun#{unique_id}
            #{::EDGECASE_CODE}
            #{::EDGECASE_OVERRIDES}
            #{runnable_code}
            path = EdgeCase::ThePath.new
            path.online_walk
            ::RunResults::SENSEI = path.sensei
          end
        end
      }
    rescue SecurityError
      ::RunResults::ERRORS = \"What do you think you're doing, Dave?\"
    rescue TimeoutError => te
      ::RunResults::ERRORS = 'Do you have an infinite loop?'
    rescue StandardError => e
      ::RunResults::ERRORS = [e.message, e.backtrace].flatten.join('<br/>')
    end
    KoanArena.send(:remove_const, :UniqueRun#{unique_id})
  "
  Thread.new { eval runnable_code, TOPLEVEL_BINDING }.value

  pass_count = (RunResults::SENSEI && RunResults::SENSEI.pass_count) || 0
  failures = (RunResults::SENSEI && RunResults::SENSEI.failures.map(&:message)) || []
  inputs = ARRAY_ORIGINAL.
    gsub("\s", "&nbsp;").
    swap_input_fields(input, pass_count, failures)

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
    #{RunResults::ERRORS}
  </div>
  </form>
  <pre style='position:absolute;top:500px'>
  </pre>
  "
  page
end

