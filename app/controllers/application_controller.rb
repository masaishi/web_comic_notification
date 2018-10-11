class ApplicationController < ActionController::Base
  before_filter :basic

  private
  def basic
    authenticate_or_request_with_http_basic do |user, pass|
      user == ENV["BASIC_USR"] && pass == ENV["BASIC_PASS"]
    end
  end
end
