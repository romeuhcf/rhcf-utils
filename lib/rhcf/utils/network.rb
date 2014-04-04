require 'socket'
module Rhcf
  module Utils
    module Network
      def self.my_interfaces
         Socket::ip_address_list.select{|a| !a.ipv4_loopback? && a.ipv4_private? }.collect(&:ip_address)
      end
    end
  end
end
