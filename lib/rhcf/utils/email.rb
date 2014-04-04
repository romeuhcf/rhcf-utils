module Rhcf
  module Utils
    module Email
      def self.get_mxs(domain) 
        Resolv::DNS.open do |dns|
          dns.getresources(domain, Resolv::DNS::Resource::IN::MX).collect{|x| x.exchange.to_s}
        end
      end
  
      def self.transmit(from, to, body, bind_interface, ehlo = 'localhost.localdomain')
        domain = to.split('@').last
      
        chat = StringIO.new 
        mx = get_mxs(domain).sample
        smtp = Net::SMTP.new(mx, 25)
        smtp.bind_at bind_interface 
        result = smtp.start(ehlo) do |smtp|
          smtp.socket.debug_output = chat
          smtp.send_message body, from, to
        end
   
        {status: result.status, string: result.string, chat: chat.string}
      end
    end
  end
end
