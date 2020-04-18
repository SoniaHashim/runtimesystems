--------------------------------------------------------------------------
--[[
tictactoe.lua
version: 200417
-----------------------------
An implementation of tic tac toe just to make sure I'm learning Lua

--]]
--------------------------------------------------------------------------
games = 0
board = {}
gameOver = false

function initBoard()
	for i = 1,3 do
		board[i] = {}
		for j = 1,3 do
			board[i][j] = i..','..j
		end
	end
end


function printBoard()
	io.write('\n')
	for i = 1,3 do
		for j = 1,3 do
			io.write(board[i][j] .. '	')
		end
		io.write('\n\n')
	end
end

function playUser()
	print 'Your turn...\n'
	while true do
		print('Select a row? [i]: ')
		local i = tonumber(io.read())
		print('Select a column? [j]: ')
		local j = tonumber(io.read())
		if i and j and i >=1 and i <=3 and j >= 1 and j <=3 then
			x = board[i][j]
			if x ~= ' x ' and x~= ' o ' then
				board[i][j] = ' x '
				return
			else
				print('Choice is not valid.')
			end
		else
			print('Choice is not valid.')
		end
	end
end

function playTurn()
	print 'My turn...'
	while true do
		local i = math.random(1,3)
		local j = math.random(1,3)
		x = board[i][j]
		if x ~= ' o ' and x~= ' x ' then
			board[i][j] = ' o '
			return
		end
	end
end

function checkGameOver()
	local winner = nil
	local a, b, c
	for x = 1,3 do
		-- Check if any row is complete
		a = board[x][1]
		b = board[x][2]
		c = board[x][3]
		if a == b and b == c and a == c then winner = a end
		-- Check if any column is complete
		a = board[1][x]
		b = board[2][x]
		c = board[3][x]
		if a == b and b == c and a == c then winner = a end
	end
	-- Check diagonals
	a = board[1][1]
	b = board[2][2]
	c = board[3][3]
	if a == b and b == c and a == c then winner = a end
	a = board[1][3]
	b = board[2][2]
	c = board[3][1]
	if a == b and b == c and a == c then winner = a end
	if winner then
		gameOver = true
		if winner == ' x ' then print 'You\'ve won! Well played.' end
		if winner == ' o ' then print 'I\'ve won! Better luck next time.' end
	end
end


while true do
	print("Play a game of tic tac toe? [yes or no]: ")
	ans = io.read()
	if ans == 'no' then
		print 'Thanks for playing!'
		return
	elseif ans == 'yes' then
		initBoard()
		math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
		games = games + 1
		print('Starting game...\n')
		printBoard()
		local nTurn = 0
		-- randomly start with user
		local startWithUser = math.random(0,1)
		if startWithUser == 1 then
			playUser()
			nTurn = nTurn + 1
		end
		-- game loop
		while not gameOver and nTurn < 9 do
			if (nTurn-startWithUser)%2 == 0 then playTurn() else playUser() end
			printBoard()
			checkGameOver()
			nTurn = nTurn + 1
			if nTurn == 9 then print 'Game over.' end
		end
		gameOver = false
	else
		print("Choice not valid. Say [yes or no]:")
	end
end
