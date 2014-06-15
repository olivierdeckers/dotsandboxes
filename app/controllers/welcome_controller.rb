class WelcomeController < ApplicationController
  def index
    @size = params[:size] || 4
  end
end
