# https://gist.github.com/afair/2480159

require 'resolv'
require 'net/smtp'

module Normailize
  module Util
    class MxCheck

      # Public: Detect if domain has valid MX records and if domain is
      # a Google Apps or FastMail domain
      #
      # Returns :valid_mx - boolean
      #         :gmail.com or fastmail.com
      def self.detect_provider(domain)
        res = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::MX)
        res.each do |r|
          mx = r.exchange.to_s
          # Google Apps for Work
          if /aspmx.*google.*\.com\.?$/i =~ mx
            return true, 'gmail.com'
          # FastMail domain
          elsif /\.messagingengine\.com\.?$/i =~ mx
            return true, 'fastmail.com'
          # Hotmail domain
          elsif /\.hotmail\.com\.?$/i =~ mx
            Normailize.logger.info("#{domain} provider is hotmail.com")
            return true, 'hotmail.com'
          # Hotmail domain
          elsif /\.yahoodns\.net\.?$/i =~ mx
            Normailize.logger.info("#{domain} provider is yahoo.com")
            return true, 'yahoo.com'
          # Might be a valid domain but invalid top or second level
          elsif 'your-dns-needs-immediate-attention.app' == mx
            return false, nil
          else
            return true, nil
          end
        end

        return false, nil
      end

      def self.account_exist?(email)
        address = email
        domain = address.split('@').last
        dns = Resolv::DNS.new

        puts "Resolving MX records for #{domain}..."
        mx_records = dns.getresources domain, Resolv::DNS::Resource::IN::MX
        mx_server  = mx_records.first.exchange.to_s
        puts "Connecting to #{mx_server}..."

        Net::SMTP.start mx_server, 25 do |smtp|
          smtp.helo "loldomain.com"
          smtp.mailfrom "test@loldomain.com"

          puts "Pinging #{address}..."

          puts "-" * 50

          begin
            smtp.rcptto address
            puts "Address probably exists."
          rescue Net::SMTPFatalError => err
            puts "Address probably doesn't exist."
          end
        end

      end

    end
  end
end