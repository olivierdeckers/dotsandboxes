
board = []
dispatcher = undefined

fillTile = (x, y, player) ->
  tile = board[y][x]
  if tile.top && tile.bottom && tile.left && tile.right
    tile.owner = player
    return true
  return false


updateBoard = (x, y, dir, player) ->
  filledTile = false
  if dir == "left"
    board[y][x].left = true
    if x > 0
      board[y][x-1].right = true
      filledTile = fillTile(x-1, y, player) || filledTile
  else if dir == "top"
    board[y][x].top = true
    if y > 0
      board[y-1][x].bottom = true
      filledTile = fillTile(x, y-1, player) || filledTile
  else if dir == "bottom"
    board[y][x].bottom = true
    if y < size-1
      board[y+1][x].top = true
      filledTile = fillTile(x, y+1, player) || filledTile
  else if dir == "right"
    board[y][x].right = true
    if x < size-1
      board[y][x+1].left = true
      filledTile = fillTile(x+1, y, player) || filledTile
  filledTile = fillTile(x, y, player) || filledTile

  return filledTile

sample_array = (array) ->
  array[Math.floor(Math.random() * array.length)]

think = () ->
  tiles = []
  tiles = tiles.concat.apply(tiles, board)
  possible_tiles = tiles.filter((tile) ->
    !(tile.top && tile.bottom && tile.left && tile.right)
  )

  tile = sample_array(possible_tiles)

  directions = ['top', 'bottom', 'left', 'right'].filter((direction) ->
    tile[direction] == false
  )

  direction = sample_array(directions)

  filledTile = updateBoard(tile.x, tile.y, direction, true)

  dispatcher.trigger('move',
    {
      game_id: game_id,
      player: 'bot',
      x: tile.x,
      y: tile.y,
      direction: direction
    },
    (->),
    (msg) ->
      console.error(msg)
  )

  if filledTile == true
    think()


connected = (player, first_player) ->
  unless first_player
    think()

moved = (x, y, dir) ->
  filledTile = updateBoard(x, y, dir, false)
  unless filledTile
    think()

ready = () ->
  size = window.size
  game_id = window.game_id

  for y in [0...size] #TODO refactor: extract board class used by both ai and game
    row = []
    for x in [0...size]
      row.push(
        {
          x: x,
          y: y,
          top: false,
          right: false,
          bottom: false,
          left: false,
          owner: undefined
        })
    board.push(row)

  dispatcher = new WebSocketRails(root_url.substring(7) + 'websocket')

  dispatcher.on_open = (data) ->
    console.log('[AI] Connection has been established: ', data)

    channel = dispatcher.subscribe(game_id)

    channel.bind('connected', (data) ->
      console.log("[AI] connected: ", data)
      if data.player != 'bot'
        connected(data.player, data.first_player)
    )
    channel.bind('moved', (data) ->
      if data.player != 'bot'
        console.log("[AI] received move: ", data)
        moved(data.x, data.y, data.direction)
    )

    dispatcher.trigger('connect',
      {
        game_id: game_id,
        size: size,
        player: 'bot'
      },
    (data) ->
      console.log('[AI] Connected')
    , (msg) ->
      console.error('[AI]', msg)
    )

$(document).ready(ready)