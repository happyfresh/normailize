require 'normailize/version'
require 'normailize/email_address'
require 'normailize/popular_domains'
require 'normailize/provider'
require 'normailize/provider/fast_mail'
require 'normailize/provider/generic'
require 'normailize/provider/gmail'
require 'normailize/provider/hotmail'
require 'normailize/provider/live'
require 'normailize/provider/yahoo'


# Development
begin
  require 'byebug'
rescue LoadError
  # nothing to do here
end

module Normailize
  # Your code goes here...
end
