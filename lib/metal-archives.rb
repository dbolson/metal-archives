require 'json'
require 'net/http'

module MetalArchives
  class Agent
    SITE_URL = 'http://metal-archives.com'
    NO_BAND_REGEXP = /span.+<\/span>/
    BAND_NAME_AND_COUNTRY_REGEXP = /(.+)\s{1}\(([a-zA-Z]{2})\)/
    ALBUM_URL_AND_NAME_REGEXP = /"(.+)">(.+)<\/a>/
    RELEASE_DATE_REGEXP = /<!--\s(.{10})\s-->/

    # An agent accesses the website and holds the HTML source.
    def initialize(year=Time.now.year)
      @year = year
      @total_results = 0
    end

    # Find the total results to search through and memoize it.
    def total_albums
      return @total_results if @total_results > 0
      results = json_results("http://www.metal-archives.com/search/ajax-advanced/searching/albums/?&releaseYearFrom=#{@year}&releaseMonthFrom=1&releaseYearTo=#{@year}&releaseMonthTo=12&_=1&sEcho=0&iColumns=4&sColumns=&iDisplayStart=1&iDisplayLength=100&sNames=%2C%2C%2C")
      @total_results = results['iTotalRecords']
      @total_results
    end

    # Finds all the url to the search results pages as they are paginated.
    def paginated_albums
      albums = []
      (total_albums / 100 + 1).times do |i|
        display_start = i * 100
        results = json_results("http://www.metal-archives.com/search/ajax-advanced/searching/albums/?&releaseYearFrom=#{@year}&releaseMonthFrom=1&releaseYearTo=#{@year}&releaseMonthTo=12&_=1&sEcho=0&iColumns=4&sColumns=&iDisplayStart=#{display_start}&iDisplayLength=100&sNames=%2C%2C%2C")
        albums << results['aaData']
      end
      albums
    end

    def band_url(album)
      band_array(album)[1]
    end

    def band_name(album)
      band_array(album)[3].match(BAND_NAME_AND_COUNTRY_REGEXP)[1]
    end

    def country(album)
      band_array(album)[3].match(BAND_NAME_AND_COUNTRY_REGEXP)[2]
    end

    def album_url(album)
      album[1].match(ALBUM_URL_AND_NAME_REGEXP)[1]
    end

    def album_name(album)
      album[1].match(ALBUM_URL_AND_NAME_REGEXP)[2]
    end

    def release_type(album)
      album[2]
    end

    def release_date(album)
      release_date_string = album[3].match(RELEASE_DATE_REGEXP)[1] # "2011-04-00"
      year, month, day = release_date_string.split('-')
      (day == '00') ? Date.civil(year.to_i, month.to_i, -1) : release_date = Date.parse(release_date_string)
    end

    private

    def json_results(url)
      response = Net::HTTP.get_response(URI.parse(url))
      data = response.body
      JSON.parse(data)
    end

    def band_array(album)
      album[0].split('"')
    end
  end
end
