require 'rubygems'
require 'sinatra'
require 'timeout'
require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/string')
require File.expand_path(File.dirname(__FILE__) + '/path_grabber')
KOAN_FILENAMES     = PathGrabber.new.koan_filenames
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")
ARRAY_ORIGINAL     = IO.read("koans/about_arrays.rb").remove_require_lines

def input
  (params[:input] || []).map{|i| i.gsub('raise','')}
end
def current_koan_name
  claimed = params[:koan].to_s
  if KOAN_FILENAMES.include? claimed
    claimed
  else
    KOAN_FILENAMES.first
  end
end
def next_koan_name
  KOAN_FILENAMES[current_koan_count]
end
def current_koan_count
  KOAN_FILENAMES.index(current_koan_name)+1
end
def current_koan
  IO.read("koans/#{current_koan_name}.rb").remove_require_lines.gsub("assert false", "assert __")
end

get '/' do
  count = 0

  runnable_code = current_koan.swap_user_values(input)
  unique_id = rand(10000)
  runnable_code = "
  require 'timeout'
  require 'test/unit/assertions'
  Test::Unit::Assertions::AssertionMessage.use_pp= false

  RESULTS = {:error => '', :failures => {}, :pass_count => 0}
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
  if failures.count > 0
    inputs = current_koan.
      gsub("\s", "&nbsp;").
      swap_input_fields(input, pass_count, failures)

    page = "<form>
    <input type='hidden' name='koan' value='#{current_koan_name}'/>
    <div nowrap='nowrap' style='white-space: nowrap; position: absolute; height: 100%; width: 60%; overflow: auto; font-family: monospace;'>
       #{inputs}
    </div>
    <div style='position: absolute; right: 0px; width: 38%;'>
      <input type='submit' value='Meditate'/><br/>
      Results
      #{pass_count}<br/>
      #{failures.values.join("\n").preify}
      #{failures.values.first.backtrace}
      #{failures.values.count}
      #{results[:error]}
    </div>
    </form>
    <pre style='position:absolute;top:500px'>
    </pre>
    "
    page
  else
    if KOAN_FILENAMES.last == current_koan_name
      "THE END"
    else
      "#{current_koan_name} has heightened your awareness.<br/>
       #{current_koan_count}/#{KOAN_FILENAMES.count} complete<br/>
        <form>
        <input type='hidden' name='koan' value='#{next_koan_name}'/>
        <input type='submit' value='Meditate on #{next_koan_name}'/></form>"
    end
  end
end
