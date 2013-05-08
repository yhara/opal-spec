require 'opal'

require 'opal/spec/spec'
require 'opal/spec/matchers'
require 'opal/spec/runner'
require 'opal/spec/expectations'
require 'opal/spec/browser_formatter'
require 'opal/spec/phantom_formatter'
require 'opal/spec/kernel'

module Opal
  Spec = OpalSpec # compatibility
end