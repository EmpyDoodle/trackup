#!/usr/bin/env ruby

require 'mechanize'
require 'nokogiri'

def convert_search(str)
  str.gsub!(' ', '+')
  str.gsub!("'", '%27')
  str.gsub!('(', '%28')
  str.gsub!(')', '%29%')
  str.gsub!('&', '%26')
  str
end

class Trackup
  def initialize(artist_name, song_name)
    @song_info = Hash.new
    @song_info[:artist] = artist_name
    @song_info[:song] = song_name

    @search_domain = "https://tunebat.com/"
    @search_url = [@search_domain, convert_search("#{artist_name} #{song_name}")].join('Search?q=')
    @session = Mechanize.new
    @results = @session.get(@search_url)
    @song_page = @results.links[5].click
    if @results.at('h1').text.include?('0 results found')
      puts("[TRACKUP][ERR] --- Could not find track listings for #{artist_name} - #{song_name}!")
      @song_page = nil
    end
  end

  def duration()
    begin
      page_sect = @song_page.search('div.row.main-attribute-label').select { |s| s.text == 'Duration' }.first
      duration = page_sect.xpath("preceding-sibling::div").text
      duration = "0#{duration}" if duration =~ /\A\d{1}\:\d{2}\z/
      @song_info[:duration] = ['00', duration].join(':')
    rescue StandardError => e
      @song_info[:duration] = ''
    end
    @song_info[:duration]
  end
end
