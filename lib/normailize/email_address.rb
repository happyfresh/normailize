require 'net/http'
require 'json'
require 'fuzzystringmatch'

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
    attr_reader :address, :catch_all, :deliverability, :disposable,
                :did_you_mean, :domain, :username, :valid_mx

    # Public: Class initializer
    #
    # address - An email address
    # options - hash
    #           :validate_account - default true, validate account using SMTP
    #
    # Raises ArgumentError if email address does not have correct format
    def initialize(address, options = { validate_account: true })
      @address = address
      @options = options
      @username, @domain = @address.split('@', 2)

      ev = Util::EmailValidator.new(@address, options)
      @did_you_mean = ev.did_you_mean
      @deliverability = ev.deliverability
      @detected_provider = ev.provider
      @catch_all = ev.catch_all
      @disposable = ev.disposable

      normalize! unless @did_you_mean
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
      # Detect provider for Google Apps and Fastmail custom domains
      # if (@options[:detect_provider] && !Provider.known_domains.include?(@domain))
      #   @valid_mx, real_domain = Util::MxCheck.detect_provider(@domain)
      # end

      # Provider.factory(real_domain || @domain)

      Provider.factory(@detected_provider || @domain)
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

    # Internal: Check spelling error
    #
    # Returns nothing
    def check_spelling!
      @domain.downcase!
      jarow = FuzzyStringMatch::JaroWinkler.create(:native)
      result = {}
      PUBLIC_DOMAINS.each do |domain|
        distance = jarow.getDistance(@domain, domain)
        result.update(distance => domain )
      end
    end
  end
end
