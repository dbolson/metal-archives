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

      #agent.search_by_year.should == search_results
      agent.send(:search_by_year).should == @search_results
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
    end
  end
end
