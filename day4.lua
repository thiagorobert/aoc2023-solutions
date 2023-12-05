-- Tested using Lua 5.4.4

input = [[Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
          Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
          Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
          Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
          Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
          Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11]]

io.write("Using Lua ", _VERSION, "!\n")

local winning_numbers = {}
local have_numbers = {}
for line in string.gmatch(input, "([^\n]+)") do
    local newline = true
    for part in string.gmatch(line, "([^|]+)") do
        local numbers = {}
        for n in string.gmatch(part, "([^ ]+)") do
            table.insert(numbers, n)
        end
        if newline then
            table.insert(winning_numbers, {table.unpack(numbers, 3)})
            newline = false
        else
            table.insert(have_numbers, numbers)
            newline = true
        end
    end
end

print("Winning numbers")
for i, v in ipairs(winning_numbers) do
  io.write(i, ": ")
  for j, n in ipairs(winning_numbers[i]) do
      io.write(n, ", ")
  end
  print()
end

print("\nHave numbers")
for i, v in ipairs(have_numbers) do
  io.write(i, ": ")
  for j, n in ipairs(have_numbers[i]) do
      io.write(n, ", ")
  end
  print()
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local sum = 0
for i, v in ipairs(have_numbers) do
  local card_value = 0
  for j, n in ipairs(have_numbers[i]) do
      if table.contains(winning_numbers[i], n) then
          if card_value == 0 then
              card_value = 1
          else
              card_value = card_value * 2
          end
      end
  end
  sum = sum + card_value
end

print("\n\n********** Part 1: the grand total: ", sum)


local copies_table = {}
for i, _ in ipairs(have_numbers) do
    copies_table[i] = 0
end

for i, v in ipairs(have_numbers) do
  local num_matches = 0
  for j, n in ipairs(have_numbers[i]) do
      if table.contains(winning_numbers[i], n) then
          num_matches = num_matches + 1
      end
  end
  for ncopies = 0, copies_table[i] do
      for copyi = i + 1, i + num_matches do
          copies_table[copyi] = copies_table[copyi] + 1
      end
  end
end


local ncards = 0
for _, ncopies in ipairs(copies_table) do
  ncards = ncards + ncopies + 1
end

print("\n\n********** Part 2: the grand total: ", ncards)