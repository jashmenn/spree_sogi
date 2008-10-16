#!/usr/bin/env ruby
$: << File.dirname(__FILE__) + "/../lib"
require 'trollop'
require 'pp'
require 'net/https'

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
unless ARGV.size >= 3
  puts "Usage: #{$0} [options] server parser_name filename"
  puts "try: #{$0} --help for help"
  exit 1
end

host, format, file = ARGV[0], ARGV[1], ARGV[2]

uri = "#{host}/sogi/orders/create/#{format}.xml"
puts "Posting to #{uri}"
resp = Net::HTTP.post_form(URI.parse(uri), {'body' => File.read(file)})
pp resp
