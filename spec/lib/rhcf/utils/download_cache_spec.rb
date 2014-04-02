require 'spec_helper'
require 'rhcf/utils/download_cache'
require 'fileutils'
require 'timecop'

describe Rhcf::Utils::DownloadCache do
  let(:img_url){"http://www.sunnyvision.com/images/cloud_cdn_icon.jpg"}
  let(:cache_of_30s){Rhcf::Utils::DownloadCache.new('cache_of_30s', 30)}
  let(:foo_cache_of_30s){Rhcf::Utils::DownloadCache.new('cache_of_30s', 30, '/tmp/foo')}
  it "should be a class" do
    Rhcf::Utils::DownloadCache.should be_instance_of(Class)
  end


  describe "#hit_fname?" do
    it "should return true if file exists and ttl is null" do
      Rhcf::Utils::DownloadCache.hit_fname?("/etc/passwd", nil).should be_true
    end 
    it "should return true if file exists and newer then ttl" do
      Rhcf::Utils::DownloadCache.hit_fname?("/etc/passwd", 20 * 365 * 24 * 3600 ).should be_true
    end 
    it "should return false if file exists and older then ttl" do
      Rhcf::Utils::DownloadCache.hit_fname?("/etc/passwd",30 ).should be_false
    end 
    it "should return false if doesn't exist" do
      Rhcf::Utils::DownloadCache.hit_fname?("/dfasd/asd/as/das/d/sada", nil).should be_false
    end 
  end


  describe "#hit?" do
    before(:each) do
      FileUtils.rm_rf "/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054ca0b0d5f8"
      FileUtils.mkdir_p "/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054a0b0d5f8"
      FileUtils.touch "/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg"
    end
    it "should return true if file downloaded and ttl is null" do
      cache_of_30s.filename_for(img_url).should == '/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg'
      cache_of_30s.hit?(img_url).should be_true
    end 
    it "should return true if file downloaded and newer then ttl" do
      cache_of_30s.hit?(img_url).should be_true
    end 
    it "should return false if file downloaded and older then ttl" do
      Timecop.travel(Time.now + 3600) do
        cache_of_30s.hit?(img_url).should be_false
      end
    end 
    it "should return false if doesn't exist" do
      FileUtils.rm "/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg"
      cache_of_30s.hit?(img_url).should be_false
    end 

    
  end

  describe "#filename_for" do
    it "should return a path with cache id , file name hash and file hash component" do
      subject.filename_for(img_url).should == '/tmp/Rhcf::Utils::DownloadCache/default/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg'
    end
  end

  describe "#download!" do
    it "should return the given file path" do
      expect do  
        out = subject.download!(img_url, "/tmp/b/c/d/a.jpg")  
        out.should == "/tmp/b/c/d/a.jpg"
      end.to_not raise_error
    end

    it "should create necessary directories and download to the given path" do
      File.unlink("/tmp/b/c/d/a.jpg")
      File.exist?("/tmp/b/c/d/a.jpg").should be_false
      expect{ subject.download!(img_url, "/tmp/b/c/d/a.jpg") }.to_not raise_error
      File.exist?("/tmp/b/c/d/a.jpg").should be_true
    end
  end

  describe "#get" do
    let(:expected_path){ '/tmp/Rhcf::Utils::DownloadCache/default/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg' }
    let(:expected_30s_path){ '/tmp/Rhcf::Utils::DownloadCache/cache_of_30s/aea455b4b37a2d4240a6b054a0b0d5f8/cloud_cdn_icon.jpg' }
    before(:each) do
      File.unlink(expected_path) rescue nil
    end

    it "should download when not exist"do
      subject.get(img_url).should == expected_path
      File.exist?(expected_path).should be_true
    end
    

    it "should download on different directory per cache_id" do
      cache_of_30s.get(img_url).should_not == expected_path
      File.exist?(expected_path).should be_false
    end
    

    it "should download on given root path" do
      foo_cache_of_30s.get(img_url).should == expected_30s_path
    end
    

    it "should redownload files older then ttl" do
      File.open(expected_30s_path, "w") {|fd| fd.write("oldycontent")}
      File.exist?(expected_30s_path).should be_true
      Timecop.travel(3600) do
        cache_of_30s.get(img_url).should == expected_30s_path
      end
      IO.read(expected_30s_path).should_not == "oldycontent"
    end
    

    it "should not redownload files newer then ttl" do
      File.open(expected_30s_path, "w") {|fd| fd.write("oldycontent")}
      File.exist?(expected_30s_path).should be_true
      Timecop.travel(Time.now + 3) do
        cache_of_30s.get(img_url).should == expected_30s_path
      end
      IO.read(expected_30s_path).should == "oldycontent"
    end
    

    it "should return absolute path to downloaded or cache file" do
      cache_of_30s.get(img_url).should == expected_30s_path
    end

    it "should raise when download problem" do
      expect{ cache_of_30s.get("hftp://3423c434v234xd")}.to raise_error
    end
  
    describe "when ttl is null" do
      it "should cache forever if ttl is null" do
      end 
    end
  end

end
