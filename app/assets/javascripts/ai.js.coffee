
board = []
dispatcher = undefined
directions = ["top", "bottom", "left", "right"]

fillTile = (board, x, y, player) ->
  tile = board[y][x]
  if tile.top && tile.bottom && tile.left && tile.right
    tile.owner = player
    return true
  return false


updateBoard = (board, x, y, dir, player) -> # TODO rewrite using getNeighbouringtile
  filledTile = false
  if dir == "left"
    board[y][x].left = true
    if x > 0
      board[y][x-1].right = true
      filledTile = fillTile(board, x-1, y, player) || filledTile
  else if dir == "top"
    board[y][x].top = true
    if y > 0
      board[y-1][x].bottom = true
      filledTile = fillTile(board, x, y-1, player) || filledTile
  else if dir == "bottom"
    board[y][x].bottom = true
    if y < size-1
      board[y+1][x].top = true
      filledTile = fillTile(board, x, y+1, player) || filledTile
  else if dir == "right"
    board[y][x].right = true
    if x < size-1
      board[y][x+1].left = true
      filledTile = fillTile(board, x+1, y, player) || filledTile
  filledTile = fillTile(board, x, y, player) || filledTile

  return filledTile

sample_array = (array) ->
  array[Math.floor(Math.random() * array.length)]

getNeighbouringTile = (x, y, dir) ->
  if dir == "top"
    return [x, y-1]
  else if dir == "bottom"
    return [x, y+1]
  else if dir == "left"
    return [x-1, y]
  else if dir == "right"
    return [x+1, y]
  else
    throw "Undefined direction"

# Build a list of all valid moves
getValidMoves = () ->
  tiles = []
  tiles = tiles.concat.apply(tiles, board)
  validMoves = []
  tiles.forEach((tile) ->
    for dir in directions
      unless tile[dir]
        validMoves.push([tile.x, tile.y, dir])
  )
  validMoves

makeTunnels = () ->
  validMoves = getValidMoves()

  captureMoves = validMoves.filter((move) ->
    [x, y] = move

    noWallDirs = directions.filter((dir) -> !board[y][x][dir]).length
    if noWallDirs == 1
      return true
    return false
  )

  if captureMoves.length > 0
    return sample_array(captureMoves)

  # Filter out moves that would give the opponent the opportunity to capture the tile
  interestingMoves = validMoves.filter((move) ->
    [x, y, dir] = move

    # Two or less openings in the current tile -> discard
    noWallDirs = directions.filter((dir) -> !board[y][x][dir]).length
    if noWallDirs <= 2
      return false

    # Two or less openings in the neighbouring tile -> discard
    [nX, nY] = getNeighbouringTile(x, y, dir)
    if nX >= 0 && nY >= 0 && nX < size && nY < size
      neighbourNoWallDirs = directions.filter((dir) -> !board[nY][nX][dir]).length
      if neighbourNoWallDirs <= 2
        return false

    return true
  )

  if interestingMoves.length == 0
    throw "No moves left"

  sample_array(interestingMoves)

growSnake = (snake, tile) ->
  if directions.filter((dir) -> !tile[dir]).length > 2
    return
  if snake.indexOf(tile) != -1
    return
  snake.push(tile)

  directions.forEach((dir) ->
    if !tile[dir]
      [x,y] = getNeighbouringTile(tile.x, tile.y, dir)
      if x >= 0 && y >= 0 && x < size && y < size
        nTile = board[y][x]
        growSnake(snake, nTile)
  )

getSnakes = () ->
  tiles = []
  tiles = tiles.concat.apply(tiles, board)

  freeTiles = tiles.filter((tile) ->
    !(tile.bottom && tile.top && tile.left && tile.right)
  )

  snakes = []
  while freeTiles.length > 0
    tile = freeTiles.pop()
    if directions.filter((dir) -> !tile[dir]).length > 2
      continue
    snake = []
    growSnake(snake, tile)
    capturable = snake.filter((tile) ->
      directions.filter((dir) -> !tile[dir]).length == 1
    ).length > 0
    snakes.push({snake: snake, capturable: capturable})
    for tile in snake
      idx = freeTiles.indexOf(tile)
      if idx != -1
        freeTiles.splice(idx, 1)
  snakes



minimax = () ->
  snakes = getSnakes()
  console.log(snakes)

  capturableTiles = 0
  snakes.forEach((snake) ->
    capturableTiles += snake.snake.length
  )
  capturableTiles -= 2
  capture = capturableTiles/2.0 <= 2

  capturableSnakes = snakes.filter((snake) -> snake.capturable && (capture || snake.snake.length != 2))
  if capturableSnakes.length > 0
    console.log("trying capturable snakes longer than 2")
    snake = sample_array(capturableSnakes).snake
    endpoints = snake.filter((tile) -> directions.filter((dir) -> !tile[dir]).length == 1)
    endpoint = sample_array(endpoints)
    return [endpoint.x, endpoint.y, directions.filter((dir) -> !endpoint[dir])[0]]


  capturableSnakesLength2 = snakes.filter((snake) -> snake.capturable && snake.snake.length == 2)
  if capturableSnakesLength2.length > 0
    console.log("trying capturable snakes of length 2")
    snake = sample_array(capturableSnakesLength2).snake
    endpoints = snake.filter((tile) -> directions.filter((dir) -> !tile[dir]).length == 2)

    if endpoints.length == 0
      endpoints = snake.filter((tile) -> directions.filter((dir) -> !tile[dir]).length == 1)
      endpoint = sample_array(endpoints)
      direction = sample_array(directions.filter((dir) -> !endpoint[dir]))
    else
      endpoint = sample_array(endpoints)
      direction = directions.filter((dir) ->
        [nx, ny] = getNeighbouringTile(endpoint.x, endpoint.y, dir)
        if nx >= 0 && ny >= 0 && nx < size && ny < size
          if snake.indexOf(board[ny][nx]) >= 0
            return false
        !endpoint[dir]
      )[0]
    return [endpoint.x, endpoint.y, direction]

  console.log("sacrificing shortest snake")
  sortedSnakes = snakes.sort((a, b) -> a.snake.length - b.snake.length)
  snake = sortedSnakes[0].snake
  tile = sample_array(snake)
  direction = sample_array(directions.filter((dir) -> !tile[dir]))
  return [tile.x, tile.y, direction]


phaseOne = true
think = () ->
  if getValidMoves().length == 0
    return

  if phaseOne
    try
      [x, y, direction] = makeTunnels()
    catch e
      console.error(e)
      phaseOne = false
      [x, y, direction] = minimax(board, 20, true, false)
  else
    [x, y, direction] = minimax(board, 20, true, false)

  filledTile = updateBoard(board, x, y, direction, true)

  console.log("[AI] sending move: #{x} #{y}, #{direction}")
  dispatcher.trigger('move',
    {
      game_id: game_id,
      player: 'bot',
      x: x,
      y: y,
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
  filledTile = updateBoard(board, x, y, dir, false)
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