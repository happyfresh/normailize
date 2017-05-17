require 'net/http'
require 'json'

module Normailize
  # Public: Class to represent an email address.
  #
  # Normalizes email addresses according to the rules given by the provider.
  #
  # Examples
  #
  #   # Compare two Gmail accounts
  #   address1 = Normailize::EmailAddress.new('Jo.Hn+sneaky@gmail.com')
  #   address2 = Normailize::EmailAddress.new('j.o.h.n@googlemail.com')
  #   address1.same_as?(address2) # => true
  #
  #   # Get normalized email address
  #   address = Normailize::EmailAddress.new('Jo.Hn+sneaky@gmail.com')
  #   address.normalized_address # => john@gmail.com
  class EmailAddress
    attr_reader :address, :username, :domain

    # Private: Simple regex to validate format of an email address
    #
    # We're deliberately ignoring a whole range of special and restricted chars
    # for the sake of simplicity. This should match 99.99% of all the email
    # addresses out there. If you allow comments (parentheses enclosed) in the
    # local or domain part of your email addresses, make sure to strip them for
    # normalization purposes. For '@' in the local part to be allowed, split
    # local and domain part at the _last_ occurrence of the @-symbol.
    EMAIL_ADDRESS_REGEX = /\A([a-z0-9_\-][a-z0-9_\-\+\.]{,62})?[a-z0-9_\-]@(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)+[a-z]{2,}\z/i

    # Public: Class initializer
    #
    # address - An email address
    # options - hash
    #           :detect_provider - default true, mx lookup
    #
    # Raises ArgumentError if email address does not have correct format
    def initialize(address, options = { detect_provider: true })
      raise ArgumentError, 'Does not look like a valid email address' unless address =~ EMAIL_ADDRESS_REGEX
      @address = address
      @options = options
      @username, @domain = @address.split('@', 2)
      normalize!
    end

    # Internal: Remove all dots from username parts
    #
    # Returns nothing
    def remove_dots
      @username.delete!('.')
    end

    # Internal: Removes everything after the first occurrence of a plus sign in
    # the username parts
    #
    # Returns nothing
    def remove_plus_part
      @username = @username.split('+', 2).first
    end

    # Internal: Removes everything after the first occurrence of a hyphen sign
    # in the username parts
    #
    # Returns nothing
    def remove_hyphen_part
      @username = @username.split('-', 2).first
    end

    # Internal: Lowercase characthers in username part
    #
    # Returns nothing
    def lowercase
      @username.downcase!
    end

    # Internal: Get provider instance for email address
    #
    # If provider is known, it returns a specific provider instance, otherwise
    # a generic provider instance is returned. When detect_provider is true
    # then it will check mx record for Google Apps and FastMail custom domain
    #
    # Returns Normailize::Provider
    def provider
      real_domain = @domain

      # Detect provider for Google Apps and Fastmail custom domains
      if (@options[:detect_provider] && !Provider.known_domains.include?(@domain))

        res = Net::HTTP.get_response(URI("http://enclout.com/api/v1/dns/show.json?url=#{@address}"))
        json_body = JSON.load(res.body) if res.is_a?(Net::HTTPSuccess)

        if !json_body['error']
          dns_entries = json_body['dns_entries']
          mx_hash = dns_entries.find { |h| h['Type'] == 'MX' }
          mx = mx_hash['RData'] if mx_hash
          if mx
            # Google Apps for Work
            if /aspmx.*google.*\.com\.?$/i =~ mx
              real_domain = 'gmail.com'
            # FastMail - https://www.fastmail.com/help/receive/domains.html
            elsif /\.messagingengine\.com\.?$/i =~ mx
              real_domain = 'fastmail.com'
            end
          end
        end
      end

      Provider.factory(real_domain)
    end

    # Public: Get normalized email address
    #
    # Returns normalized address according to the rules specified by 
    # the provider.
    def normalized_address
      "#{@username}@#{@domain}"
    end

    # Public: Determine if two email addresses are the same
    #
    # Performs a comparison of the normalized username and provider
    #
    # Returns true if same or false if not
    def same_as?(address)
      (@username == address.username) && self.provider.same_as?(address.provider)
    end

    private

    # Internal: Normalize email address according to rules specified by
    # the provider
    #
    # Returns nothing
    def normalize!
      @domain.downcase!
      provider.modifications.each { |m| self.send(m) if self.respond_to?(m) }
    end

    # Internal: Detect Google Apps and FastMail domains by mx lookup.
    # It skips provider check if error occur in mx lookup.
    # 
    # Returns real domain
    # def detect_provider
    #   Provider.known_domains.include?(@domain) || !@options[:detect_provider]
    #     return @domain
    #   end

    #   res = Net::HTTP.get_response(URI("http://enclout.com/api/v1/dns/show.json?url=#{@address}"))
    #   json_body = JSON.load(res.body) if res.is_a?(Net::HTTPSuccess)

    #   if json_body['error']
    #     return @domain
    #   else
    #     dns_entries = json_body['dns_entries']
    #     mx_hash = dns_entries.find { |h| h['Type'] == 'MX' }
    #     mx = mx_hash['RData'] if mx_hash
    #     if mx
    #       # Google Apps for Work
    #       if /aspmx.*google.*\.com\.?$/i =~ mx
    #         return 'gmail.com'
    #       # FastMail - https://www.fastmail.com/help/receive/domains.html
    #       elsif /\.messagingengine\.com\.?$/i =~ mx
    #         return 'fastmail.com'
    #       end
    #     else
    #       return @domain
    #     end
    #   end
    # end
  end
end
