#!/usr/bin/env ruby
$: << File.dirname(__FILE__) + "/../lib"
require 'trollop'
require 'pp'

opts = Trollop::options do
  version "#{$0} (c) 2008 Nate Murray"
  banner <<-EOS
A utility to post an xml file to an endpoint 

Usage:
       #{$0} [options] server parser_name filename

Examples: 
  #{$0} http://localhost:4000 amazon /path/to/foo.xml

Options:
EOS

  # opt :debug, "Debug mode"
  # opt :dry, "Print XML to STDOUT and die"
  # opt :verbose, "Operate loudly"

end
unless ARGV.size > 0
  puts "try: #{$0} --help for help"
  exit 1
end
