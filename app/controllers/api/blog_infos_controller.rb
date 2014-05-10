class Api::BlogInfosController < ApplicationController
  respond_to :json
  def show
    respond_with(BlogInfo.info_all.to_json)
  end
end