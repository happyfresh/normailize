# https://gist.github.com/afair/2480159

require 'resolv'
require 'net/smtp'

module Normailize
  module Util
    class EmailValidator

      attr_reader :catch_all, :deliverability, :did_you_mean, :disposable,
                  :domain, :provider, :valid_mx

      # Private: Simple regex to validate format of an email address
      #
      # We're deliberately ignoring a whole range of special and restricted chars
      # for the sake of simplicity. This should match 99.99% of all the email
      # addresses out there. If you allow comments (parentheses enclosed) in the
      # local or domain part of your email addresses, make sure to strip them for
      # normalization purposes. For '@' in the local part to be allowed, split
      # local and domain part at the _last_ occurrence of the @-symbol.
      EMAIL_ADDRESS_REGEX = /\A([a-z0-9_\-][a-z0-9_\-\+\.]{,62})?[a-z0-9_\-]@(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)+[a-z]{2,}\z/i

      # Deliverability
      DELIVERABLE   = 'deliverable'.freeze
      UNDELIVERABLE = 'undeliverable'.freeze
      UNKNOWN       = 'unknown'.freeze

      def initialize(address, options = {})
        raise ArgumentError, 'Does not look like a valid email address' unless address =~ EMAIL_ADDRESS_REGEX

        @address = address.downcase
        @username, @domain = @address.split('@', 2)
        @provider = nil
        @valid_mx = false
        @mx_records = []
        @deliverability = UNDELIVERABLE
        @did_you_mean = nil
        @catch_all = false
        @disposable = false

        if DISPOSABLE_EMAILS.include?(@domain)
          @deliverability = DELIVERABLE
          @catch_all = true
          @disposable = true
        else
          detect_provider!
          check_account_existence! if options[:validate_account]
          check_spelling! unless @valid_mx
        end
      end


    private

      def check_account_existence!
        return unless @valid_mx

        mx_server = @mx_records.first

        @deliverability = smtp_check(@address, mx_server)

        # Return if domain is a known public domain
        return if PUBLIC_DOMAINS.include?(@domain)

        # Check catch-all policy for non known public domain
        catch_all_address = "catch-all-address-UQ9wE+zsbsd6QQPL@#{@domain}"
        catch_all_deliverability = smtp_check(catch_all_address, mx_server)
        @catch_all = true if catch_all_deliverability == DELIVERABLE
      end

      def check_spelling!
        # No need to check known public domain
        return if PUBLIC_DOMAINS.include?(@domain)

        jarow = FuzzyStringMatch::JaroWinkler.create(:native)
        result = {}
        PUBLIC_DOMAINS.each do |domain|
          distance = jarow.getDistance(@domain, domain)
          result.update(distance => domain)
        end

        closest_domain = result.sort.last
        if closest_domain[0] >= 0.928
          @did_you_mean = "#{@username}@#{closest_domain[1]}"
        end
      end

      # Public: Detect if @domain has valid MX records and if @domain is
      # a Google Apps or FastMail @domain
      #
      # Returns :valid_mx - boolean
      #         :gmail.com or fastmail.com
      def detect_provider!
        res = Resolv::DNS.new.getresources(@domain, Resolv::DNS::Resource::IN::MX)
        res.each do |r|
          mx = r.exchange.to_s
          @mx_records << mx
          @valid_mx = true
          # Google Apps for Work
          if /aspmx.*google.*\.com\.?$/i =~ mx
            @provider = 'gmail.com'
          # FastMail @domain
          elsif /\.messagingengine\.com\.?$/i =~ mx
            @provider = 'fastmail.com'
          # Hotmail @domain
          elsif /\.hotmail\.com\.?$/i =~ mx
            @provider = 'hotmail.com'
          # Hotmail @domain
          elsif /\.yahoodns\.net\.?$/i =~ mx
            @provider = 'yahoo.com'
          # Might be a valid @domain but invalid top or second level
          elsif mx.empty? || 'your-dns-needs-immediate-attention.app' == mx
            @valid_mx = false
          end
        end
      end

      def smtp_check(email, mx_server)
        Net::SMTP.start mx_server, 25 do |smtp|
          smtp.helo "mailinator.com"
          smtp.mailfrom "sender@mailinator.com"

          begin
            smtp.rcptto email
            DELIVERABLE
          rescue Exception => e
            check_spelling!
            if e.message =~ /^550|^552|^521/
              UNDELIVERABLE
            else
              UNKNOWN
            end

          ensure
            smtp.finish
          end
        end

      rescue Exception => e
        check_spelling!
        UNKNOWN
      end

    end
  end
end