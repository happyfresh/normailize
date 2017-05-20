# https://gist.github.com/afair/2480159

require 'resolv'
require 'net/smtp'

module Normailize
  module Util
    class EmailValidator

      attr_reader :domain, :provider, :valid_mx, :deliverability, :did_you_mean

      def initialize(address, options = {})
        @address = address
        @username, @domain = @address.split('@', 2)
        @provider = nil
        @valid_mx = false
        @mx_records = []
        @deliverability = 'unknown'
        @did_you_mean = nil

        detect_provider!
        check_account_existence! if options[:validate_account]
        check_spelling! unless @valid_mx
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

      def check_account_existence!
        return unless @valid_mx

        puts "Resolving MX records for #{@domain}..."
        mx_server  = @mx_records.first
        puts "Connecting to #{mx_server}....."

        puts "Pinging #{@address}....."

        Net::SMTP.start mx_server, 25 do |smtp|
          smtp.helo "koprol.com"
          smtp.mailfrom "fajar@koprol.com"

          begin
            smtp.rcptto @address
            @deliverability = 'deliverable'
          rescue Exception => e
            check_spelling!
            p "#{@address} can't be delivered"
            @deliverability = 'undeliverable' if e.message =~ /^550/
          ensure
            smtp.finish
          end
        end

      rescue
        p "#{@address} can't be delivered, unknown error"

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

    end
  end
end