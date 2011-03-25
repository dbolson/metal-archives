require 'mechanize'

module MetalArchives
  SITE_URL = 'http://metal-archives.com'

  class Agent
    # An agent accesses the website and holds the HTML source.
    def initialize(year=Time.now.year)
      begin
        @agent = Mechanize.new
      rescue Exception => e
        puts "\nError accessing metal-archives.com on initialization: #{e}"
        return nil
      end
      @year = year
    end

    # Goes straight to the search results page for the given year.
    def search_by_year
      begin
        @agent.get("#{SITE_URL}/advanced.php?release_year=#{@year}&p=1")
      rescue Exception => e
        puts "\nError accessing metal-archives.com's search results page: #{e}"
        return nil
      end
    end

    # Finds all the url to the search results pages as they are paginated.
    def paginated_result_urls
      # need the first page because it's not a url
      urls = ["/advanced.php?release_year=#{@year}&p=1"]
      begin
        search_by_year.search('body table:nth-child(2n) tr:first-child a').each do |link|
          urls << link['href']
        end
      rescue Exception => e
        puts "\nError accessing metal-archives.com's paginated result urls: #{e}"
      ensure
        return urls
      end
    end

    # Finds all the urls to the albums on a given search results page.
    def album_urls(url)
      urls = []
      begin
        page = @agent.get(SITE_URL + url)
        if page
          page.encoding = 'iso-8859-1' if !page.nil? && page.encoding != 'iso-8859-1' # needed for foreign characters
          page.search('body table:nth-child(2n) tr td:nth-child(3n) a').each do |link|
            urls << link['href']
          end
        end
      rescue Exception => e
        puts "\nError accessing metal-archives.com's album urls: #{e}"
        return nil
      end
      return urls
    end

    # Finds the following fields on an album's page:
    # album name
    # band name
    # album's record label
    # album's release date
    # album's release type (full-length, demo, split, DVD, etc.)
    def album_from_url(url)
      begin
        page = @agent.get(SITE_URL + '/' + url)
        if page
          page.encoding = 'iso-8859-1' if !page.nil? && page.encoding != 'iso-8859-1' # needed for foreign characters
          band_and_album = page.search('body table tr:first-child .tt').text

        # these fields can be in one of the following forms, so we need to find the specific fields appropriately:
        # "\n\t\t", "Demo", ", NazgÃ»l Distro & Prod.", "", "2011", "\t\t\t"
        # "\n\t\t", "Demo", ", Deific Mourning", "", "\n\n\t\tJanuary ", "2011", "\t\t\t"
        # "Full-length", ", ARX Productions", "", "\n\n\t\tFebruary 25th, ", "2011", "\t\t\t"
          album_fields = page.search('body table:nth-child(2n) tr:first-child > td:first-child').first.children
        end
      rescue Exception => e
        puts "\nError accessing metal-archives.com's album information: #{e}"
        return nil
      end

      {
        :album => album_from_content(band_and_album),
        :band => band_from_content(band_and_album),
        :label => label_from_content(album_fields),
        :release_date => release_date_from_content(album_fields),
        :release_type => release_type_from_content(album_fields),
        :url => url
      }
    end

    def total_albums
      begin
        page = search_by_year
        album_total = page.search('body table:nth-child(2n) tr:first-child b').first.content.match(/\sof\s(\d+)/)
        if album_total.nil?
          0
        else
          album_total[1].to_i
        end
      rescue Exception => e
        puts "\nError accessing metal-archives.com's paginated result urls: #{e}"
        return nil
      end
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
