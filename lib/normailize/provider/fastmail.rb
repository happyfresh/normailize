module Normailize
  module Provider

    # Internal: A provider to represent Gmail and Googlemail
    class Fastmail
      include Normailize::Provider

      # Fastmail addresses work on both fastmail.com and fastmail.fm
      set_domains 'fastmail.com', 'fastmail.fm'

      # A normalized Fastmail address is lowercased and everything after a
      # plus sign is removed from the username part.
      # https://www.fastmail.com/help/receive/addressing.html
      # TODO: whatever@username.fastmail.com -> username@fastmail.com
      set_modifications :lowercase, :remove_plus_part
    end
  end
end
