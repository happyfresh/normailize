require "normailize/version"
require "normailize/email_address"
require "normailize/provider"
require "normailize/provider/generic"
require "normailize/provider/gmail"
require "normailize/provider/live"
require "normailize/provider/hotmail"
require "normailize/provider/yahoo"
require "normailize/provider/fastmail"

# Development
begin
  require 'byebug'
rescue LoadError
  # nothing to do here
end

module Normailize
  # Your code goes here...
end
