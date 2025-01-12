module Tonal
  require "csv"
  require "erb"
  require "zip"
  require "caxlsx"
  require "typhoeus"
  require "pathname"
  require "readline"
  require "terminal-table"
  require "active_support/inflector"
  require "tonal/tools"
  require "tonal/strings"
  require "tonal/scale"
  require "tonal/sequence"
  require "tonal/analysis"
  require "tonal/attributions"
  Dir[File.join(__dir__, "interfaces", "*.rb")].each{|file| require file }
  Dir[File.join(__dir__, "sequences", "*.rb")].each{|file| require file }
  Dir[File.join(__dir__, "scales", "*.rb")].each{|file| require file }
end
