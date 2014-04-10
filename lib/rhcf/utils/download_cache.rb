require 'uri'
require 'open-uri'
require 'fileutils'
require 'digest/md5'

module Rhcf
  module Utils
    class DownloadCache
      include FileUtils
      def initialize(cache_id= 'default', ttl = nil, root_path = nil)
        @cache_id = cache_id
        @ttl = ttl
        @root_path ||= "/tmp/#{self.class.name}"
      end
  
  
      def get(url)
        outfile = filename_for(url)
        return outfile if self.class.hit_fname?(outfile, @ttl) # here goes the cache
        download!(url, outfile)
      rescue 
        if File.exist?(outfile)
          File.unlink(outfile) 
        end
        raise
      end
 

      def download!(url, outfile)
        mkdir_p(File.dirname(outfile))
        File.open(outfile, 'wb') do |fd|
          open(url, "rb") do |down|
            fd.write(down.read)
          end
        end
        outfile
      end 

      def hit?(url)
        outfile = filename_for(url)
        self.class.hit_fname?(outfile, @ttl) # here goes the cache
      end
  
      def self.hit_fname?(fname, ttl)
        
        if File.exist?(fname) 
          if ttl
            File::Stat.new(fname).ctime > Time.now - ttl
          else 
            true
          end
        else
          false
        end
      end
  
      def filename_for(url)
        hash =  Digest::MD5.hexdigest(url)
        uri = URI(url)
        basename = File.basename(uri.path)
        File.join(@root_path, @cache_id, hash, basename) 
      end

    end
  end
end


