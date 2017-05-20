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

      def initialize(address, options = {})
        raise ArgumentError, 'Does not look like a valid email address' unless address =~ EMAIL_ADDRESS_REGEX

        @address = address
        @username, @domain = @address.split('@', 2)
        @provider = nil
        @valid_mx = false
        @mx_records = []
        @deliverability = 'undeliverable'
        @did_you_mean = nil
        @catch_all = false
        @disposable = false

        if DISPOSABLE_EMAILS.include?(@domain)
          @deliverability = 'deliverable'
          @catch_all = true
          @disposable = true
        else
          detect_provider!
          check_account_existence! if options[:validate_account]
          check_spelling! unless @valid_mx
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

      # TODO handle catch-all policy
      def check_account_existence!
        return unless @valid_mx

        mx_server  = @mx_records.first

        puts "Connecting to #{mx_server}....."
        puts "Pinging #{@address}....."

        @deliverability = smtp_check(@address, mx_server)

        # Check for catch-all policy for non public domain
        if !Provider.known_domains.include?(@domain)
          p "Checking for catch-all policy"
          catch_all_address = "catch-all-address-UQ9wE+zsbsd6QQPL@#{domain}"
          catch_all = smtp_check(catch_all_address, mx_server)
          @catch_all = true if catch_all == 'deliverable'
        end
      end

      def check_spelling!
        @domain.downcase!
        jarow = FuzzyStringMatch::JaroWinkler.create(:native)
        result = {}
        DOMAINS.each do |domain|
          distance = jarow.getDistance(@domain, domain)
          result.update(distance => domain)
        end

        closest_domain = result.sort.last
        if closest_domain[0] > 0.9
          @did_you_mean = "#{@username}@#{closest_domain[1]}"
        end
      end

    private

      def smtp_check(email, mx_server)
        Net::SMTP.start mx_server, 25 do |smtp|
          smtp.helo "koprol.com"
          smtp.mailfrom "fajar@koprol.com"

          begin
            smtp.rcptto email
            deliverability = 'deliverable'
          rescue Exception => e
            check_spelling!
            p "#{address} can't be delivered"
            deliverability = 'undeliverable' if e.message =~ /^550/
          ensure
            smtp.finish
          end
        end

      rescue
        deliverability = 'unknown'

      ensure
        deliverability
      end

    end
  end
end