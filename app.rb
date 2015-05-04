require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'json'

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Not Found']
end

get '/world' do
	content_type 'application/json', :charset => 'utf-8'
	'[{:msg=>"Server is not defined"]'
end

get '/world/:server' do
	content_type 'application/json', :charset => 'utf-8'

  @server = params[:server].split(/(\W)/).map(&:capitalize).join

  html = open("https://secure.tibia.com/community/?subtopic=worlds&world=#{@server}")

	doc = Nokogiri::HTML(html)
	doc.encoding = 'utf-8'

	rows = doc.search('//tr[starts-with(@class, "Odd") or starts-with(@class, "Even")]')
		@details = rows.collect do |row|
      detail = {}
      [
        [:name, 'td[1]/a[@href]/text()'],
        [:level, 'td[2]/text()'],
        [:vocation, 'td[3]/text()'],
      ].each do |name, xpath|
        detail[name] = row.at_xpath(xpath).to_s.strip
      end
      detail
	  end
	  if @details.any?
	  	 JSON.pretty_generate(@details)
		else
			'[{:msg=>"World with this name doesn\'t exist!"]'
		end
end