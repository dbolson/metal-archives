# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MetalArchives" do
  before do
    json = JSON.parse(File.read(File.dirname(__FILE__) + '/json/search_results.json'))
    @results = JSON.parse(json.to_json)
    @agent = MetalArchives::Agent.new
  end

  describe "#total_albums" do
    it "shows the total amount of albums" do
      @agent.stub(:json_results).and_return(@results)
      @agent.total_albums.should == 2939
    end
  end

  describe "#paginated_albums" do
    it "finds all the albums" do
      @agent.stub(:json_results).and_return(@results)
      @agent.paginated_albums.first[0].should == ["<a href=\"http://www.metal-archives.com/bands/...Do_Fundo..._Abismo/3540326997\" title=\"...Do Fundo... Abismo (BR)\">...Do Fundo... Abismo</a>", "<a href=\"http://www.metal-archives.com/albums/...Do_Fundo..._Abismo/Da_Escurid%C3%A3o/304910\">Da Escuridão</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
      @agent.paginated_albums.last[99].should == ["<a href=\"http://www.metal-archives.com/bands/Alcoholism/3540326304\" title=\"Alcoholism (DE)\">Alcoholism</a>", "<a href=\"http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798\">Abhängigkeit</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
    end
  end

  describe "#band_url" do
    it "shows the band's url" do
      album = ["<a href=", "http://www.metal-archives.com/bands/Alcoholism/3540326304", " title=", "Alcoholism (DE)", ">Alcoholism</a>"]
      @agent.stub(:band_array).and_return(album)
      @agent.band_url(album).should == 'http://www.metal-archives.com/bands/Alcoholism/3540326304'
    end
  end

  describe "#band_name" do
    it "shows the band's name" do
      album = ["<a href=", "http://www.metal-archives.com/bands/Alcoholism/3540326304", " title=", "Alcoholism (DE)", ">Alcoholism</a>"]
      @agent.stub(:band_array).and_return(album)
      @agent.band_name(album).should == 'Alcoholism'
    end
  end

  describe "#country" do
    it "shows the band's country" do
      album = ["<a href=", "http://www.metal-archives.com/bands/Alcoholism/3540326304", " title=", "Alcoholism (DE)", ">Alcoholism</a>"]
      @agent.stub(:band_array).and_return(album)
      @agent.country(album).should == 'DE'
    end
  end

  describe "#album_url" do
    it "shows the album's url" do
      album = ["<a href=\"http://www.metal-archives.com/bands/Alcoholism/3540326304\" title=\"Alcoholism (DE)\">Alcoholism</a>", "<a href=\"http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798\">Abhängigkeit</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
      @agent.stub(:album).and_return(album)
      @agent.album_url(album).should == 'http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798'
    end
  end

  describe "#album_name" do
    it "shows the album's name" do
      album = ["<a href=\"http://www.metal-archives.com/bands/Alcoholism/3540326304\" title=\"Alcoholism (DE)\">Alcoholism</a>", "<a href=\"http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798\">Abhängigkeit</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
      @agent.stub(:band_array).and_return(album)
      @agent.album_name(album).should == 'Abhängigkeit'
    end
  end

  describe "#release_type" do
    it "shows the release type" do
      album = ["<a href=\"http://www.metal-archives.com/bands/Alcoholism/3540326304\" title=\"Alcoholism (DE)\">Alcoholism</a>", "<a href=\"http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798\">Abhängigkeit</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
      @agent.stub(:band_array).and_return(album)
      @agent.release_type(album).should == 'Demo'
    end
  end

  describe "#release_date" do
    it "shows the release date" do
      album = ["<a href=\"http://www.metal-archives.com/bands/Alcoholism/3540326304\" title=\"Alcoholism (DE)\">Alcoholism</a>", "<a href=\"http://www.metal-archives.com/albums/Alcoholism/Abh%C3%A4ngigkeit/303798\">Abhängigkeit</a>", "Demo", "April 2011 <!-- 2011-04-00 -->"]
      @agent.stub(:band_array).and_return(album)
      @agent.release_date(album).should == Date.parse('2011-04-30')
    end
  end
end
