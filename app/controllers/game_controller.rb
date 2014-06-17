class GameController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    controller_store[:board_count] = 0
    controller_store[:boards] = {}
  end

  def connect
    logger.debug 'connecting'

    size = message[:size]
    board = Board.new(size)
    board_id = controller_store[:board_count] += 1
    controller_store[:boards][board_id] = board

    logger.debug "board_id: #{board_id}"

    trigger_success({:board_id => board_id})
  end

  def move
    logger.debug "moving"
    board_id = message[:board_id]
    board = controller_store[:boards][board_id]

    x = message[:x]
    y = message[:y]
    direction = message[:direction]

    player_filled_tile = board.move(x, y, direction, true)

    if !player_filled_tile
      we_filled_tile = true
      while we_filled_tile
        x, y, dir = randomMove(board)
        logger.debug("#{x}, #{y}, #{dir}")
        we_filled_tile = board.move(x, y, dir, false)

        logger.debug "move: x: #{x}, y: #{y}, dir: #{dir}"

        send_message :move, {:x => x, :y => y, :direction => dir}
      end
    end

    trigger_success
  end

  def randomMove(board)
    free_tiles = board.tiles.flatten.select { |tile| !tile.captured? }
    tile = free_tiles.sample
    dir = [:@top, :@bottom, :@left, :@right].select {|dir| !tile.instance_variable_get(dir)}.sample.to_s[1..-1]

    return tile.x, tile.y, dir
  end
end