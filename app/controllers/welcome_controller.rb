class WelcomeController < ApplicationController

  def index

  end

  def join
    @size = params[:id]
    @id = params[:id]
  end

  def game
    @size = params[:size] || 4
    @game_id = params[:id]
    @player = params[:player]
  end
end
