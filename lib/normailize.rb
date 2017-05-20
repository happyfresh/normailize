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
require 'normailize/util/mx_check'
require 'normailize/util/email_validator'

require 'logger'

# Development
begin
  require 'byebug'
rescue LoadError
  # nothing to do here
end

module Normailize
  file = file = File.open('detected_domains.log', File::WRONLY | File::APPEND | File::CREAT)
  @@logger = Logger.new(file)
  @@logger.level = Logger::INFO

  def self.logger
    @@logger
  end
end
