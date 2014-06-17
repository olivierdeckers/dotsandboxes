class Game
  attr_accessor :player1, :player2, :board
  def initialize(board)
    @player1 = nil
    @player2 = nil
    @board = board
  end
end