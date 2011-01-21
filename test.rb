require 'rubygems'
require 'sinatra'
require 'haml'
require 'timeout'
require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/string')
require File.expand_path(File.dirname(__FILE__) + '/path_grabber')
KOAN_FILENAMES     = PathGrabber.new.koan_filenames
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")
ARRAY_ORIGINAL     = IO.read("koans/about_arrays.rb").remove_require_lines

require 'drb/drb'
SANDBOX_URI = 'druby://localhost:8787'

runner = DRbObject.new(nil, SANDBOX_URI)

def input
  (params[:input] ||= []).map{|i| i.gsub('raise','')}
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

def runnable_code
  code = current_koan.swap_user_values(input)
  unique_id = rand(1000)
  <<-RUNNABLE_CODE
    require 'timeout'
    require 'test/unit/assertions'
    Test::Unit::Assertions::AssertionMessage.use_pp= false

    RESULTS = {:error => nil, :failures => {}, :pass_count => 0}
    $SAFE = 3
      begin
        Timeout.timeout(2) {
          module KoanArena
            module UniqueRun#{unique_id}
              #{::EDGECASE_CODE}
              #{::EDGECASE_OVERRIDES}
              #{code}
              path = EdgeCase::ThePath.new
              path.online_walk
              RESULTS[:pass_count] = path.sensei.pass_count
              RESULTS[:failures] = path.sensei.failures
            end
          end
          KoanArena.send(:remove_const, :UniqueRun#{unique_id})
        }
      rescue SecurityError => se
        RESULTS[:error] = \"What do you think you're doing, Dave? \"
      rescue TimeoutError => te
        RESULTS[:error] = 'Do you have an infinite loop?'
      rescue StandardError => e
        RESULTS[:error] = ['standarderror', e.message, e.backtrace, e.inspect].flatten.join('<br/>')
      end
      RESULTS
  RUNNABLE_CODE
end

get '/' do
  return haml '%pre= runnable_code' if params[:dump]

  count = 0
  results = runner.run(runnable_code).buf
  # results = Thread.new { eval runnable_code, TOPLEVEL_BINDING }.value
  @pass_count = results[:pass_count]
  @failures   = results[:failures]
  @error      = results[:error]

  if @error
    return "#{@error} <br/><br/> Click your browser back button to return."
  elsif @failures.count > 0
    @inputs = current_koan.gsub("\s", "&nbsp;").gsub("<<","&lt;&lt;").swap_input_fields(input, @pass_count, @failures)
    return haml :koans
  else
    if KOAN_FILENAMES.last == current_koan_name
      return haml :end
    else
      return haml :next_koan
    end
  end
end
