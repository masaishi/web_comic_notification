class ApplicationController < ActionController::Base

  private
  def basic
    authenticate_or_request_with_http_basic('BA') do |n, p|
      n == ENV["BASIC_USER"] && p == ENV["BASIC_PASS"]
    end
  end
end
