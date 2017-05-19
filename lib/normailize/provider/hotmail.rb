module Normailize
  module Provider

    # Internal: A provider to represent Hotmail
    class Hotmail
      include Normailize::Provider

      # A hotmail account only works on the hotmail.com domain
      set_domains 'hotmail.com', 
                  'hotmail.com.tw',
                  'hotmail.ca',
                  'hotmail.ch',
                  'hotmail.co',
                  'hotmail.co.id',
                  'hotmail.co.jp',
                  'hotmail.co.kr',
                  'hotmail.co.th',
                  'hotmail.co.uk',
                  'hotmail.co.za',
                  'hotmail.com',
                  'hotmail.com.au',
                  'hotmail.com.hk',
                  'hotmail.com.my',
                  'hotmail.de',
                  'hotmail.dk',
                  'hotmail.es',
                  'hotmail.fi',
                  'hotmail.fr',
                  'hotmail.gr',
                  'hotmail.it',
                  'hotmail.my',
                  'hotmail.nl',
                  'hotmail.ph',
                  'hotmail.se',
                  'hotmail.sg',
                  'live.ca',
                  'live.cn',
                  'live.co',
                  'live.co.kr',
                  'live.co.uk',
                  'live.co.za',
                  'live.com',
                  'live.com.au',
                  'live.com.my',
                  'live.com.ph',
                  'live.com.sg',
                  'live.de',
                  'live.dk',
                  'live.fr',
                  'live.hk',
                  'live.ie',
                  'live.in',
                  'live.it',
                  'live.jp',
                  'live.nl',
                  'live.no',
                  'live.ru',
                  'live.se',
                  'livemail.tw',
                  'msn.com',
                  'msn.cn',
                  'outlook.be',
                  'outlook.co',
                  'outlook.co.id',
                  'outlook.co.th',
                  'outlook.com',
                  'outlook.com.au',
                  'outlook.com.vn',
                  'outlook.de',
                  'outlook.dk',
                  'outlook.fr',
                  'outlook.jp',
                  'outlook.kr',
                  'outlook.my',
                  'outlook.ph',
                  'outlook.sg',
                  'plasa.com'

      # A normalized hotmail address is lowercased and everything after a plus sign is removed
      set_modifications :lowercase, :remove_plus_part
    end
  end
end
