--[[
UCSB-themed memory word game for a single player.
--]]

math.randomseed(os.time())

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function swap(table, index_1, index_2)
  table[index_1], table[index_2] = table[index_2], table[index_1]
end

function shuffle(table)
  for i=#table,1,-1 do
    local j = math.random(i)
    swap(table, i, j)
  end
end

function generate_is_flipped(length)
  indices = {}
  for i=1,length do
    indices[i] = 0
  end
  return indices
end

function get_card_choice(is_flipped_top, is_flipped_bottom)
  io.write("Enter the index of the first card to flip:\t")
  local i = tonumber(io.read())
  while (i > #is_flipped_top or i < 1 or is_flipped_top[i] == 1) do
    io.write("Invalid index.\n")
    io.write("Enter the index of the first card to flip:\t")
    i = tonumber(io.read())
  end
  io.write("Enter the index of the second card to flip:\t")
  local j = tonumber(io.read())
  while (j > #is_flipped_bottom or j < 1 or is_flipped_bottom[j] == 1) do
    io.write("Invalid index.\n")
    io.write("Enter the index of the second card to flip:\t")
    j = tonumber(io.read())
  end
  return i, j
end

function remove_last_line()
  io.write(('\b \b'):rep(1000))
end

function display_half(words, is_flipped, clear, sleep_time)
    for i=1,#words do
      if is_flipped[i] == 0 then
        io.write("???   ")
      else
        io.write(words[i] .. "   ")
      end
    end
    if clear == false then
      io.write("\n")
      return
    end
    io.flush()
    sleep(sleep_time)
    remove_last_line()
end

function display(words_1, words_2, is_flipped_top, is_flipped_bottom, clear, sleep_time)
  display_half(words_1, is_flipped_top, clear, sleep_time)
  display_half(words_2, is_flipped_bottom, clear, sleep_time)
end

function initialize_game()
  words_1 = {"sand", "sunshine", "Freebirds", "surfing", "DP"}
  shuffle(words_1)
  words_2 = {"sand", "sunshine", "Freebirds", "surfing", "DP"}
  shuffle(words_2)
  is_flipped_top = generate_is_flipped(#words_1)
  is_flipped_bottom = generate_is_flipped(#words_1)
  display(words_1, words_2, is_flipped_top, is_flipped_bottom, false, 0)
  return 0, words_1, words_2, is_flipped_top, is_flipped_bottom
end

function flip_cards(index_1, index_2, words_1, words_2, is_flipped_top, is_flipped_bottom, num_correct)
  is_flipped_top[index_1] = 1
  is_flipped_bottom[index_2] = 1
  display(words_1, words_2, is_flipped_top, is_flipped_bottom, true, 2)
  if words_1[index_1] ~= words_2[index_2] then
      is_flipped_top[index_1] = 0
      is_flipped_bottom[index_2] = 0
  else
    num_correct = num_correct + 1
  end
  display(words_1, words_2, is_flipped_top, is_flipped_bottom, false, 0)
  io.write("Number of correct guesses: " .. num_correct .. "\n")
  return num_correct
end

num_correct, words_1, words_2, is_flipped_top, is_flipped_bottom = initialize_game()
while num_correct ~= #words_1 do
  index_1, index_2 = get_card_choice(is_flipped_top, is_flipped_bottom)
  num_correct = flip_cards(index_1, index_2, words_1, words_2, is_flipped_top, is_flipped_bottom, num_correct)
end
