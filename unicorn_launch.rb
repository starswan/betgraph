# frozen_string_literal: true

#
# $Id$
#
SITENAME = ARGV[0]
URL = "http://#{Settings.sitesurl}/sites.json"

def getSite(sitename)
  JSON.parse(HTTParty.get(URL)).find { |site| site["hostname"] == sitename }
end

site = getSite SITENAME
start_port = site["port"].to_i
port_count = site["port_count"].to_i
listen_args = start_port.upto(start_port + port_count - 1).collect { |port| "-l #{port}" }.join(" ")
puts "unicorn_rails #{listen_args}"
# puts 'unicorn -c config/unicorn.rb'
