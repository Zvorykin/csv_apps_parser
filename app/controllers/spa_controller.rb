class SpaController < ApplicationController
  skip_forgery_protection

  def index; end

  def parse
    result = ParseCsvService.new(params[:file]).call

    render json: { html: result }
  end
end
