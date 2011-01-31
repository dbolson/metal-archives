require 'mechanize'

module MetalArchives
  class Agent
    # An agent accesses the website and holds the HTML source.
    def initialize
      @agent = Mechanize.new
    end

    # Goes straight to the search results page for the given year.
    def search_by_year(year=Time.now.year)
      @agent.get("http://metal-archives.com/advanced.php?release_year=#{year}")
      #search_results_html = File.open(File.dirname(__FILE__) + '/../spec/html/search_results.html')
      #Nokogiri::HTML(search_results_html)
    end

    # Finds all the links to the search results pages as they are paginated.
    def paginated_result_links(year=nil)
      @agent.search_by_year(year).search('body table:nth-child(2n) tr:first-child a').collect do |link|
        link['href']
      end
    end

    # Finds all the links to the albums on a given search results page.
    def album_links_from_url(url)
      @agent.get(url).search('body table:nth-child(2n) tr td:nth-child(3n) a').collect do |link|
        link['href']
      end
    end

    # Finds the following fields on an album's page:
    # album name
    # band name
    # album's record label
    # album's release date
    # album's release type (full-length, demo, split, DVD, etc.)
    def album_from_url(url)
      page = @agent.get(url)
      #page.encoding = 'iso-8859-1' if !page.nil? && page.encoding != 'iso-8859-1'      
      band_and_album = page.search('body table tr:first-child .tt').text

      # these fields can be in one of the following forms, so we need to find the specific fields appropriately:
      # "\n\t\t", "Demo", ", NazgÃ»l Distro & Prod.", "", "2011", "\t\t\t"
      # "\n\t\t", "Demo", ", Deific Mourning", "", "\n\n\t\tJanuary ", "2011", "\t\t\t"
      # "Full-length", ", ARX Productions", "", "\n\n\t\tFebruary 25th, ", "2011", "\t\t\t"
      album_fields = page.search('body table:nth-child(2n) tr:first-child > td:first-child').first.children

      {
        :album => album_from_content(band_and_album),
        :band => band_from_content(band_and_album),
        :label => label_from_content(album_fields),
        :release_date => release_date_from_content(album_fields),
        :release_type => release_type_from_content(album_fields)
      }
    end

    private

    # The band and and album fields are together, so we need to split them apart.
    def album_from_content(content)
      content.split(' - ')[1].strip
    end

    # The band and and album fields are together, so we need to split them apart.
    def band_from_content(content)
      content.split(' - ')[0].strip
    end

    # The label will probably always have ", " in front, so we need to get rid of that but also allow
    # just the text if it does not have this string.
    def label_from_content(content)
      label = content[2].text
      label.match(/,\s(.+)/) ? $1 : label
    end

    # The date can be in one of the following forms:
    # year
    # month, year
    # month, day, year
    def release_date_from_content(content)
      date = content[4].text
      if content.size == 7
        date << content[5].text

        split_date = date.split(' ')
        if split_date.size == 2 # only have month and year
          date = DateTime.
            new(
              split_date[1].to_i,
              Date::MONTHNAMES.find_index(split_date[0]),
              -1
            ).
            strftime('%B %e %Y')

            # need to use block to get s, the current captured backreference of the regexp because
            # gsub doesn't see the $n-style references
            date.gsub!(/\s(\d{1,2})\s/) do |s|
              "#{MetalArchives.ordinalize(s.rstrip)}, "
            end
        end

      else # only have year
        date = "December 31st, #{date}"
      end
      date.strip
    end

    # Finds the release type in the assumed spot.
    def release_type_from_content(content)
      content[1].text
    end
  end

  # Taken from Rails active_support/core_ext/string/inflections.rb but not referenced so the
  # entire library is needed for this one method.
  def self.ordinalize(number)
    if (11..13).include?(number.to_i % 100)
      "#{number}th"
    else
      case number.to_i % 10
        when 1; "#{number}st"
        when 2; "#{number}nd"
        when 3; "#{number}rd"
        else    "#{number}th"
      end
    end
  end
end

#rescue Mechanize::ResponseCodeError => e
#  ::Rails.logger.error "\nError accessing metal-archives.com on initialization."
#end
