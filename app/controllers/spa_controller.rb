class SpaController < ApplicationController
  skip_forgery_protection

  def index; end

  def parse
    _status, payload = ParseCsvService.new(params[:file]).call

    render json: { apps: payload[:result].values }
  end
end
