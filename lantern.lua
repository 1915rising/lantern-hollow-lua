-- Lantern Hollow - a mini text adventure in Lua.
--
-- You wake in a hollow beneath the hills with an unlit lantern. Find the
-- tinderbox, light the lantern at the old shrine, and carry the light
-- back to the hollow gate to win. A grue-adjacent darkness is patient,
-- but the game is kind: no deaths, just wandering.
-- Commands: look, go <dir> / n/s/e/w, take <item>, use <item>, inventory (i), quit.
-- Usage: lua lantern.lua [--seed N]   (seed varies a couple of details)

local seed = 20261125
for i = 1, #arg do
  if arg[i] == "--seed" and arg[i + 1] then seed = tonumber(arg[i + 1]) or seed end
end
math.randomseed(seed)

local rooms = {
  hollow = {
    name = "The Hollow",
    desc = "A round hollow under the hill, grass soft as felt. The gate home stands north, shut fast. Your lantern sits by the cold fire pit, unlit.",
    exits = { south = "brook", east = "grove" },
    items = { "lantern" },
  },
  brook = {
    name = "The Brook",
    desc = "A clear brook chuckles over flat stones. Something glints in the shallows.",
    exits = { north = "hollow" },
    items = { "flint" },
  },
  grove = {
    name = "The Grove",
    desc = "Old trees lean together, whispering. A tinderbox hangs from a low branch, left by some earlier traveller.",
    exits = { west = "hollow", south = "shrine" },
    items = { "tinderbox" },
  },
  shrine = {
    name = "The Old Shrine",
    desc = "A mossy shrine, and on it an ever-burning candle in a glass bell. No wind reaches this place.",
    exits = { north = "grove" },
    items = {},
  },
  gate = {
    name = "The Hollow Gate",
    desc = "The gate home.",
    exits = {},
    items = {},
  },
}

local player = { room = "hollow", inv = {}, lantern_lit = false }

local function has(item)
  for _, v in ipairs(player.inv) do if v == item then return true end end
  return false
end

local function room_has(item)
  for _, v in ipairs(rooms[player.room].items) do if v == item then return true end end
  return false
end

local function remove_room_item(item)
  local items = rooms[player.room].items
  for i, v in ipairs(items) do
    if v == item then table.remove(items, i) return end
  end
end

local function look()
  local r = rooms[player.room]
  print("\n== " .. r.name .. " ==")
  print(r.desc)
  if #r.items > 0 then print("You see: " .. table.concat(r.items, ", ")) end
  local dirs = {}
  for d in pairs(r.exits) do dirs[#dirs + 1] = d end
  table.sort(dirs)
  print("Exits: " .. table.concat(dirs, ", "))
end

print("=== LANTERN HOLLOW ===")
print("Light your lantern at the old shrine, then return north through the hollow gate.")
print("Commands: look, go <dir> (or n/s/e/w), take <item>, use <item>, i, quit.")
look()

local won = false
while true do
  io.write("\n> ")
  io.flush()
  local line = io.read()
  if not line then print() break end
  line = line:lower():gsub("^%s+", ""):gsub("%s+$", "")
  local verb, rest = line:match("^(%S+)%s*(.-)$")
  if verb == "quit" or verb == "q" then
    break
  elseif verb == "look" or verb == "l" then
    look()
  elseif verb == "i" or verb == "inventory" then
    if #player.inv == 0 then print("You carry nothing.")
    else print("You carry: " .. table.concat(player.inv, ", ")) end
  elseif verb == "take" or verb == "get" then
    if rest ~= "" and room_has(rest) then
      remove_room_item(rest)
      player.inv[#player.inv + 1] = rest
      print("Taken: " .. rest)
    else
      print("There is no '" .. rest .. "' here.")
    end
  elseif verb == "use" then
    if rest == "tinderbox" then
      if not has("tinderbox") then print("You don't have the tinderbox.")
      elseif not has("flint") then print("The tinder is damp. You need a flint to strike a spark.")
      elseif not has("lantern") then print("You have nothing to light.")
      elseif player.room ~= "shrine" then print("The wind snuffs every spark. You need a sheltered flame - the shrine candle.")
      else
        player.lantern_lit = true
        print("By the shrine candle your lantern catches, steady and gold. The hollow will let you home now.")
      end
    else
      print("You can't use that here.")
    end
  elseif verb == "go" or verb == "n" or verb == "s" or verb == "e" or verb == "w"
      or verb == "north" or verb == "south" or verb == "east" or verb == "west" then
    local dir = rest
    if verb ~= "go" then dir = ({ n = "north", s = "south", e = "east", w = "west" })[verb] or verb end
    if player.room == "hollow" and dir == "north" then
      if player.lantern_lit then
        player.room = "gate"
        won = true
        break
      else
        print("The gate is shut fast, and the dark beyond it is absolute. You need a lit lantern.")
      end
    elseif rooms[player.room].exits[dir] then
      player.room = rooms[player.room].exits[dir]
      look()
    else
      print("You can't go that way.")
    end
  elseif verb == "" then
    -- ignore empty lines
  else
    print("I don't understand '" .. line .. "'.")
  end
end

print("\n=== GAME OVER ===")
if won then
  print("Lantern held high, you pass the hollow gate and walk home by its light. You win!")
else
  print("You leave the hollow in darkness. The lantern waits for another evening.")
end
