require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MetalArchives" do
  context "searching by year" do
    before do
      search_results_html = File.open(File.dirname(__FILE__) + '/html/search_results.html')
      @search_results = Nokogiri::HTML(search_results_html)
      @mechanize = stub('Mechanize')
      Mechanize.stub!(:new).and_return(@mechanize)
    end

    it "should GET the results page" do
      @mechanize.stub!(:get).and_return(@search_results)
      agent = MetalArchives::Agent.new

      agent.search_by_year.should == @search_results
    end

    context "with a results page" do
      it "should find the paginated result links" do
        @mechanize.stub!(:search_by_year).and_return(@search_results)
        agent = MetalArchives::Agent.new

        links = []
        (2..16).each do |i|
          links << "/advanced.php?band_name=&band_status=&genre=&themes=&origin=0&location=&bandLabel=&release_name=&release_type=&label=&release_year=2011&p=#{i}"
        end
        agent.paginated_result_links.should == links
      end

      it "should find the album links" do
        @mechanize.stub!(:search_by_year).and_return(@search_results)
        @mechanize.stub!(:get).and_return(@search_results)
        agent = MetalArchives::Agent.new

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
end
