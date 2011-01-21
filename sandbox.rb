require 'drb/drb'
require 'rubygems'
require 'haml'
require 'timeout'
require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/string')
require File.expand_path(File.dirname(__FILE__) + '/path_grabber')
KOAN_FILENAMES     = PathGrabber.new.koan_filenames
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")
ARRAY_ORIGINAL     = IO.read("koans/about_arrays.rb").remove_require_lines

URI = 'druby://localhost:8787'

class Runner
  def run(code)
    eval(code, TOPLEVEL_BINDING)
  end
end

runner = Runner.new

DRb.start_service(URI, runner)
DRb.thread.join
