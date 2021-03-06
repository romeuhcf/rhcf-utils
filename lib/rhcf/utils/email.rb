require 'resolv'
require 'stringio'
require 'socket'
require 'net/smtp'
module Net
  class SMTP
    def socket
      @socket
    end

    def bind_at(ip)
      @bind_at = ip
    end

    def tcp_socket(address, port)
      in_addr = Socket.pack_sockaddr_in(0, @bind_at) if @bind_at

      out_addr = Socket.pack_sockaddr_in(port, address)
      s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      s.bind(in_addr) if @bind_at
      s.connect(out_addr)
      s
    end
  end
end


module Rhcf
  module Utils
    module Email
      def self.get_mxs(domain)
        Resolv::DNS.open do |dns|
          dns.getresources(domain, Resolv::DNS::Resource::IN::MX).collect{|x| x.exchange.to_s}
        end
      end

      def self.transmit(from, to, body, bind_interface=nil, ehlo = Socket.gethostname)

        domain = to.split('@').last

        chat = StringIO.new
        mxs = get_mxs(domain).shuffle

        begin

          mx = mxs.shift
          smtp = Net::SMTP.new(mx, 25)
          smtp.bind_at bind_interface if bind_interface
          result = smtp.start(ehlo) do |smtp|
            smtp.socket.debug_output = chat
            smtp.send_message body, from, to
          end

          return {status: result.status, string: result.string.to_s.strip, chat: chat.string.to_s.strip}

        rescue Errno::ECONNREFUSED, Timeout::Error => e
          if mxs.empty?
            raise
          else
            retry
          end
        end

      end
    end
  end
end
