class Board

  def initialize(size)
    @tiles = []
    (1..size).each do
      row = []
      (1..size).each do
        row << Tile.new
      end
      @tiles << row
    end

    @
  end




end