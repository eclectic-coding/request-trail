class PingController < ApplicationController
  def index
    render plain: "pong"
  end
end