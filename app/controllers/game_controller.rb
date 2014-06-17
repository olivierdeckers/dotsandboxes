class GameController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    controller_store[:games] = {}
  end

  def connect
    logger.debug 'Player connecting'

    size = message[:size]
    game_id = message[:game_id]
    player = message[:player]

    unless controller_store[:games][game_id]
      controller_store[:games][game_id] = Game.new(Board.new(size))
    end

    game = controller_store[:games][game_id]
    first_player = false
    if game.player1 === nil
      game.player1 = player
      first_player = true
    elsif game.player2 === nil
      game.player2 = player
    else
      logger.debug 'Game already full'
      trigger_failure({:message => 'Game already full'})
    end

    WebsocketRails[game_id].trigger(:connected, {:player => player, :first_player => first_player})

    logger.debug "Player #{player} connected to game #{game_id}"

    trigger_success
  end

  def move
    game_id = message[:game_id]
    game = controller_store[:games][game_id]
    board = game.board

    player = message[:player]
    x = message[:x]
    y = message[:y]
    direction = message[:direction]

    logger.debug "Player #{player} moving: x: #{x}, y: #{y}, dir: #{direction}"

    player_filled_tile = board.move(x, y, direction, true)

    WebsocketRails[game_id].trigger(:moved, {:player => player, :x => x, :y => y, :direction => direction})

    # if !player_filled_tile
    #   we_filled_tile = true
    #   while we_filled_tile
    #     x, y, dir = random_move(board)
    #     logger.debug("#{x}, #{y}, #{dir}")
    #     we_filled_tile = board.move(x, y, dir, false)
    #
    #     logger.debug "move: x: #{x}, y: #{y}, dir: #{dir}"
    #
    #     send_message :move, {:x => x, :y => y, :direction => dir}
    #   end
    # end

    trigger_success
  end

  def random_move(board)
    free_tiles = board.tiles.flatten.select { |tile| !tile.captured? }
    tile = free_tiles.sample
    dir = [:@top, :@bottom, :@left, :@right].select {|dir| !tile.instance_variable_get(dir)}.sample.to_s[1..-1]

    return tile.x, tile.y, dir
  end
end