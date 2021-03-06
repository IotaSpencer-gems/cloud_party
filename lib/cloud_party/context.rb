# frozen_string_literal: true

require 'httparty'
require 'cloud_party/config'
module CloudParty
  module Context
    def self.included(base)
      base.define_singleton_method(:cfg) do
        CloudParty::Config.new
      end
    end
  end
end
