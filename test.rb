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

class FakeFile
  CONTENT = "this\nis\na\ntest"

  def self.gimme(x=nil, &block)
    ff = FakeFile.new
    return block.call(ff) if block
    ff
  end

  def initialize
    @lines = CONTENT.split("\n")
  end

  def gets
    @current_line_index ||= 0
    line = @lines[@current_line_index]
    @current_line_index += 1
    "#{line}\n" if line
  end

  def close;end

  def self.exist?(name)
    raise TypeError unless name.respond_to? :to_str
    name.to_str == 'example_file.txt'
  end

  def self.open(*x)
    CONTENT
  end
end

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
  unique_id = rand(10000)
  code = current_koan.swap_user_values(input).gsub(" ::About", " About").gsub("File", "FakeFile").gsub(" open(", "FakeFile.gimme(")
  global_code = code.split('class').first
  <<-RUNNABLE_CODE
    require 'timeout'
    require 'test/unit/assertions'
    Test::Unit::Assertions::AssertionMessage.use_pp= false

    RESULTS = {:failures => {}, :pass_count => 0}
    $SAFE = 3
    Timeout.timeout(2) {
      #{global_code}
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
    RESULTS
  RUNNABLE_CODE
end

get '/' do
  return haml '%pre= runnable_code' if params[:dump]

  count = 0
  begin
    results = Thread.new { eval runnable_code, TOPLEVEL_BINDING }.value
  rescue SecurityError => se
    error = "What do you think you're doing, Dave?"
  rescue TimeoutError => te
    error = 'Do you have an infinite loop?'
  rescue StandardError => e
    error = ['standarderror', e.message, e.backtrace, e.inspect].flatten.join('<br/>')
  rescue Exception => e
    error = ['syntax error', e.message].flatten.join('<br/>')
  end
  @pass_count = results[:pass_count]
  @failures   = results[:failures]
  @error      = results[:error]
  puts "failures (#{@failures.count}) #{@failures.inspect}"

  if @error
    return "#{@error.gsub(/\n/, "<br/>")} <br/><br/> Click your browser back button to return."
  elsif @failures.count > 0
    @inputs = current_koan.gsub("\s", "&nbsp;").gsub("<","&lt;").swap_input_fields(input, @pass_count, @failures)
    return haml :koans
  else
    if KOAN_FILENAMES.last == current_koan_name
      return haml :end
    else
      return haml :next_koan
    end
  end
end
