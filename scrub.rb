#!/usr/bin/env ruby
#############################################
# Scrub:rb
#
# Automated Web Scraper
# written in Ruby
#
# (c) 2019, Dr.Kameleon
#############################################

require 'awesome_print'
require 'colorize'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'sdl4r'

require './utils.rb'

def getProject(n)
	n.children("project").map{|p| p.values[0]}[0]
end

def getUrls(n)
	n.children("urls").map{|u| u.values[0]}
end

def getFeed(n)
	n.children("feed").map{|f| f.values}.flatten
end

def getExtract(n)
	extracts = []
	n.children("extract").each{|extract|
		new_extract = {
			"pattern" => extract.values[0],
			"as" => extract.attributes["as"],
			"filter" => extract.children("filter").map{|f| f.values},
			"select" => extract.children("select").map{|s| s.values}
		}

		extracts << new_extract
	}

	return extracts
end

def getNoko(url, feed)
	final_url = url.gsub("$$", feed)
	return Nokogiri::HTML(open(final_url))
end

def processProject(proj)
	result = {}

	urls 	= getUrls(proj)
	feed 	= getFeed(proj)
	extract = getExtract(proj)

	urls.each{|u|
		feed.each{|f|
			n = getNoko(u,f)

			result[f] = {}

			extract.each{|e|
				puts "url: #{u}, feed: #{f}, extract: #{e["as"]}"
				
				interm = n.search(e["pattern"]).map{|s| s.content}

				e["filter"].each{|f|
					if f.count == 1
						interm = interm.reject{|x| x.send(f[0])}
					elsif f.count == 2
						interm = interm.reject{|x| x.send(f[0],f[1])}
					end
				}

				e["select"].each{|s|
					if s.count == 1
						interm = interm.select{|x| x.send(s[0])}
					elsif s.count == 2
						interm = interm.select{|x| x.send(s[0],s[1])}
					end
				}

				result[f][e["as"]] = interm
			}
		}
	}

	return result
end

$input 		= ARGV[0]
$project 	= SDL4R::read(File.read($input))

res = processProject($project)

File.open("output/#{File.basename($input).gsub(".sdl",".json")}", "w"){|f|
	f.write(JSON.pretty_generate(res))
}

#############################################
# This is the end
# my only friend, the end...
#############################################