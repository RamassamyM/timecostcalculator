require 'json'
class SettingsController < ApplicationController
  def index
    raw_settings = policy_scope(Setting).new.read
    @settings = JSON.pretty_generate(raw_settings)
  end
end
