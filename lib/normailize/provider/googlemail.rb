module Normailize
  module Provider
    class GoogleMail
      include Normailize::Provider

      set_domains 'googlemail.com'

      set_modifications :lowercase, :remove_plus_part
    end
  end
end
