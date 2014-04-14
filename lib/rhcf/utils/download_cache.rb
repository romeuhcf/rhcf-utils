require 'uri'
require 'net/http'
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
      end
 

      def download!(url, outfile)
        uri = URI(url)
        expected_file_size = nil
        Net::HTTP.start(uri.host) do |http|
          resp = http.get(uri.path)

          expected_file_size = resp.body.size
          mkdir_p(File.dirname(outfile))
          File.open(outfile, 'wb') do |fd|
            fd.write(resp.body)
          end
        end

        if expected_file_size != File.size(outfile)
          raise "Different file size expected: '%d' bytes got: '%d' bytes " % [expected_file_size, File.size(outfile)]
        end
        raise "Empty file" if File.zero?(outfile)
        outfile
      end 

      def hit?(url)
        outfile = filename_for(url)
        self.class.hit_fname?(outfile, @ttl) # here goes the cache
      end
  
      def self.hit_fname?(fname, ttl)
        
        if File.exist?(fname) and !File.zero?(fname)
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
        File.join(@root_path, @cache_id, hash_tree(hash), basename) 
      end

      def hash_tree(hash)
        [*(hash[0,3].split('')) ,hash].join('/')
      end

    end
  end
end


