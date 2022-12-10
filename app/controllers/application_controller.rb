# frozen_string_literal: true

#
# $Id$
#
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? || request.format.xml? }

  before_action :set_active_sports

protected

  def set_active_sports
    @active_sports = Sport.active.order(:name)
  end

  def semi_verify_authenticity_token
    # logger.debug "Request #{request.public_methods}"
    # verify_authenticity_token unless request.xml_http_request?
    # verify_authenticity_token unless request.local? or remote_ip == ip
    verify_authenticity_token unless request.remote_ip == request.ip
  end
end
