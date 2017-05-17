# https://gist.github.com/afair/2480159

require 'resolv'

module Util
  class MxCheck

    def self.detect_provider(domain)
      res = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::MX)
      res.map { |r| [r.exchange.to_s, IPSocket::getaddress(r.exchange.to_s), r.preference] }

      return mxs
    end

  end
end
