# Lantern Hollow (Lua)

A mini text adventure written in plain Lua (5.4, no external libraries).

You wake in a hollow beneath the hills with an unlit lantern. Explore
four locations — the hollow, a brook, a grove, and an old shrine —
gather the lantern, a flint, and a tinderbox, light the lantern by the
shrine's sheltered candle, and carry the light north through the hollow
gate to win. There are no deaths and no fail state; the puzzle is the
route and the order of the three items.

## Run

```sh
lua lantern.lua             # any Lua 5.x interpreter works
lua lantern.lua --seed 42   # accepted for consistency; layout is fixed
```

Commands: `look`, `go <direction>` (or just `n` / `s` / `e` / `w`),
`take <item>`, `use <item>`, `inventory` (`i`), `quit`.

## Tested envelope

- Runs clean on Lua 5.4.7 with no warnings.
- Verified end to end with scripted stdin playthroughs: the full winning
  route (take lantern → take flint → take tinderbox → use tinderbox at
  the shrine → go north) reaches the win screen, and a quit path reaches
  the game-over screen.
