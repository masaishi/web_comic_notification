class ApplicationController < ActionController::Base

  private
  def basic
    http_basic_authenticate_with :name => ENV["BASIC_USR"], :password => ENV["BASIC_PASS"] if Rails.env == "production"
  end
end
