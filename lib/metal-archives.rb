require 'mechanize'

module MetalArchives
  # An agent accesses the website and holds the HTML source.
  class Agent
    def initialize
      @agent = Mechanize.new
    end

    def search_by_year(year=Time.now.year)
      @agent.get("http://metal-archives.com/advanced.php?release_year=#{year}")
      #search_results_html = File.open(File.dirname(__FILE__) + '/../spec/html/search_results.html')
      #Nokogiri::HTML(search_results_html)
    end

    def paginated_result_links(year=nil)
      results = @agent.search_by_year(year)
      results.search('body table:nth-child(2n) tr:first-child a').collect do |link|
        link['href']
      end
    end

    def album_links_from_url(url)
      page = @agent.get(url)
      results = page.search('body table:nth-child(2n) tr td:nth-child(3n) a').collect do |link|
        link['href']
      end
    end
  end
end

#rescue Mechanize::ResponseCodeError => e
#  ::Rails.logger.error "\nError accessing metal-archives.com on initialization."
#end
