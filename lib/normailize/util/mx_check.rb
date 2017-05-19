# https://gist.github.com/afair/2480159

require 'resolv'

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

    end
  end
end