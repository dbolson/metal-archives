# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MetalArchives" do
  context "with an agent" do
    context "that searches by year" do
      before do
        search_results_html = File.open(File.dirname(__FILE__) + '/html/search_results.html')
        @search_results = Nokogiri::HTML(search_results_html)
        @mechanize = stub('Mechanize')
        Mechanize.stub!(:new).and_return(@mechanize)
      end

      it "should find the total number of albums" do
        @mechanize.stub!(:get).and_return(@search_results)
        agent = MetalArchives::Agent.new

        agent.total_albums.should == 757
      end

      it "should get the results page" do
        @mechanize.stub!(:get).and_return(@search_results)
        agent = MetalArchives::Agent.new

        agent.search_by_year.should == @search_results
      end

      context "with a results page" do
        it "should find the paginated result links" do
          agent = MetalArchives::Agent.new
          agent.stub!(:search_by_year).and_return(@search_results)

          links = (1..16).collect do |i|
            "/advanced.php?release_year=2011&p=#{i}"
          end
          agent.paginated_result_links.should == links
        end

        it "should find the album links" do
          @mechanize.stub!(:get).and_return(@search_results)
          agent = MetalArchives::Agent.new
          agent.stub!(:search_by_year).and_return(@search_results)

          links = [
            "release.php?id=296061", "release.php?id=295756", "release.php?id=294429", "release.php?id=295451", "release.php?id=295197",
            "release.php?id=289824", "release.php?id=295519", "release.php?id=295457", "release.php?id=288298", "release.php?id=296048",
            "release.php?id=290116", "release.php?id=295059", "release.php?id=291931", "release.php?id=296081", "release.php?id=295301",
            "release.php?id=294242", "release.php?id=294032", "release.php?id=295436", "release.php?id=295797", "release.php?id=294481",
            "release.php?id=290911", "release.php?id=295988", "release.php?id=295717", "release.php?id=293534", "release.php?id=295111",
            "release.php?id=290063", "release.php?id=294761", "release.php?id=293839", "release.php?id=295202", "release.php?id=294083",
            "release.php?id=294702", "release.php?id=265276", "release.php?id=293421", "release.php?id=295295", "release.php?id=293910",
            "release.php?id=295567", "release.php?id=296037", "release.php?id=296064", "release.php?id=288749", "release.php?id=290749",
            "release.php?id=295806", "release.php?id=294017", "release.php?id=296098", "release.php?id=294092", "release.php?id=295551",
            "release.php?id=290740", "release.php?id=295410", "release.php?id=293189", "release.php?id=296140", "release.php?id=291295"
          ]
          agent.album_links_from_url(agent.paginated_result_links.first).should == links
        end
      end
    end

    context "with an album page" do
      context "with only a release year" do
        it "should find the band information" do
          search_results_html = File.open(File.dirname(__FILE__) + '/html/album_result.html')
          @search_results = Nokogiri::HTML(search_results_html)
          @mechanize = stub('Mechanize')
          Mechanize.stub!(:new).and_return(@mechanize)
          @mechanize.stub!(:get).and_return(@search_results)
          agent = MetalArchives::Agent.new
          album_link_from_url = "release.php?id=000001"

          agent.album_from_url(album_link_from_url).should == {
            :album => 'Fn-2+Fn-1=Fn',
            :band => 'A Tree',
            :label => 'NazgÃ»l Distro & Prod.',
            :release_date => 'December 31st, 2011',
            :release_type => 'Demo',
            :url => 'release.php?id=000001'
          }
        end
      end

      context "with only a release month and year" do
        it "should find the band information" do
          search_results_html = File.open(File.dirname(__FILE__) + '/html/album_result3.html')
          @search_results = Nokogiri::HTML(search_results_html)
          @mechanize = stub('Mechanize')
          Mechanize.stub!(:new).and_return(@mechanize)
          @mechanize.stub!(:get).and_return(@search_results)
          agent = MetalArchives::Agent.new
          album_link_from_url = "release.php?id=000001"

          agent.album_from_url(album_link_from_url).should == {
            :album => 'Flesh Torn in Twilight',
            :band => 'Acephalix',
            :label => 'Deific Mourning',
            :release_date => 'April 30th, 2011',
            :release_type => 'Demo',
            :url => 'release.php?id=000001'
          }
        end
      end

      context "with a release month, day, and year" do
        it "should find the band information" do
          search_results_html = File.open(File.dirname(__FILE__) + '/html/album_result2.html')
          @search_results = Nokogiri::HTML(search_results_html)
          @mechanize = stub('Mechanize')
          Mechanize.stub!(:new).and_return(@mechanize)
          @mechanize.stub!(:get).and_return(@search_results)
          agent = MetalArchives::Agent.new
          album_link_from_url = "release.php?id=000001"

          agent.album_from_url(album_link_from_url).should == {
            :album => 'The Mirror of Deliverance',
            :band => 'A Dream of Poe',
            :label => 'ARX Productions',
            :release_date => 'February 25th, 2011',
            :release_type => 'Full-length',
            :url => 'release.php?id=000001'
          }
        end
      end
    end
  end

  it "ordinalizes a number" do
    numbers = {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      5 => '5th',
      6 => '6th',
      7 => '7th',
      8 => '8th',
      9 => '9th',
      10 => '10th',
      32 => '32nd',
      43 => '43rd',
      64 => '64th',
      100 => '100th'
    }
    numbers.each do |k, v|
      MetalArchives.ordinalize(k).should == v
    end
  end
end
