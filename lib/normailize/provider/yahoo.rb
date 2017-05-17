module Normailize
  module Provider

    # Internal: A provider to represent Live
    class Yahoo
      include Normailize::Provider

      # Yahoo Mail Plus accounts,per https://en.wikipedia.org/wiki/Yahoo!_Mail#Email_domains
      set_domains 'yahoo.com.ar',
                  'yahoo.com.au',
                  'yahoo.at',
                  'yahoo.be/fr',
                  'yahoo.be/nl',
                  'yahoo.com.br',
                  'ca.yahoo.com',
                  'qc.yahoo.com',
                  'yahoo.com.co',
                  'yahoo.com.hr',
                  'yahoo.cz',
                  'yahoo.dk',
                  'yahoo.fi',
                  'yahoo.fr',
                  'yahoo.de',
                  'yahoo.gr',
                  'yahoo.com.hk',
                  'yahoo.hu',
                  'yahoo.co.in/yahoo.in',
                  'yahoo.co.id',
                  'yahoo.ie',
                  'yahoo.co.il',
                  'yahoo.it',
                  'yahoo.co.jp',
                  'yahoo.com.my',
                  'yahoo.com.mx',
                  'yahoo.ae',
                  'yahoo.nl',
                  'yahoo.co.nz',
                  'yahoo.no',
                  'yahoo.com.ph',
                  'yahoo.pl',
                  'yahoo.pt',
                  'yahoo.ro',
                  'yahoo.ru',
                  'yahoo.com.sg',
                  'yahoo.co.za',
                  'yahoo.es',
                  'yahoo.se',
                  'yahoo.ch/fr',
                  'yahoo.ch/de',
                  'yahoo.com.tw',
                  'yahoo.co.th',
                  'yahoo.com.tr',
                  'yahoo.co.uk',
                  'yahoo.com',
                  'yahoo.com.vn',
                  'rocketmail.com'

      # Use hyphens - http://www.cnet.com/forums/discussions/did-yahoo-break-disposable-email-addresses-mail-plus-395088/
      set_modifications :lowercase, :remove_hyphen_part
    end
  end
end
