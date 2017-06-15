module Normailize
  module Provider
    class GoogleApps
      include Normailize::Provider

      set_domains 'googleapps.com'

      set_modifications :lowercase, :remove_plus_part
    end
  end
end
