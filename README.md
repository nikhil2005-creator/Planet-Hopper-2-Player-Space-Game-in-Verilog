# Planet Hopper — A 2-Player Space Race in Verilog

## The story

Two spaceships race across a small solar system of **5 planets**. Each player
picks a starting planet. From then on the ships fly on autopilot: each one
orbits its current planet for a fixed number of revolutions, collects (or loses)
energy, then travels to the next planet on a fixed route.

Each ship starts with **50 reward points**. Some planets are **toxic** and take
points away. Others are **rewarding** and add points. After **20 clock cycles**
the game ends, and the ship with more points wins.

Your task is to write the Verilog module `game` that runs this race.

---

## Module interface

Your module **must** use exactly this name and these ports:

```verilog
module game(
    input        clk,        // clock
    input        rst,        // asynchronous, active-high reset
    input  [2:0] pos1,       // Player 1 starting planet (0-4)
    input  [2:0] pos2,       // Player 2 starting planet (0-4)
    output [1:0] winner_ID   // result (see below)
);
```

| `winner_ID` | Meaning |
|---|---|
| `1` | Player 1 won |
| `2` | Player 2 won |
| `3` | Tie, **or game still in progress** |

---

## The planets

The input code `0`–`4` selects Planets 1–5.

| Input code | Planet | Revolutions (`REV`) | Effect on points | Next planet (input code) |
|:-:|:-:|:-:|:-:|:-:|
| 0 | Planet 1 | 1 | **− 1** (toxic) | Planet 2 (code 1) |
| 1 | Planet 2 | 0 | **− 3** (toxic) | Planet 4 (code 3) |
| 2 | Planet 3 | 4 | **+ 2** (reward) | Planet 2 (code 1) |
| 3 | Planet 4 | 3 | **+ 2** (reward) | Planet 3 (code 2) |
| 4 | Planet 5 | 2 | **+ 4** (reward) | Planet 3 (code 2) |

---

## Game rules (exact behaviour)

Both players are fully independent. They follow the same rules at the same time.

### 1. Reset
While `rst = 1` (asynchronous, active-high):
- Both players' points are set to **50**.
- Both players are placed in the **IDLE** state. The game hasn't started yet.
- The cycle counter is set to **0**.
- Each player's revolution counter is set to **0**.

### 2. Cycle counter
- A counter counts clock cycles from the first clock edge after reset is released.
- On each rising clock edge where `cycle < 20`, the counter goes up by 1.
- When `cycle` reaches **20**, the game is **over**: every register freezes and
  stays frozen until the next reset.

### 3. Player state machine
Each player is always in one of these states:

| State | What happens on the next clock edge |
|---|---|
| **IDLE** | Load the starting planet from `pos1` / `pos2`. This takes 1 cycle. |
| **On a planet** | If the revolution counter `rev` is **not** equal to the planet's `REV`: add 1 to `rev` and stay on the planet. If `rev == REV`: apply the planet's effect to the points, set `rev` back to 0, and move to **TRAVEL** with the planet's "next planet" as the destination. |
| **TRAVEL** | Arrive at the destination planet. This takes 1 cycle. |

In practice:
- A ship stays on a planet for **`REV + 1` cycles**. The points change on the
  last of those cycles, as the ship leaves.
- Every jump between planets costs **1 extra TRAVEL cycle**.
- Planet 2 has `REV = 0`. A ship there leaves on its very first cycle.

### 4. Point limits
Points are stored in **8 bits**, from 0 to 255.
- A subtraction that would go below 0 gives **0**.
- An addition that would go above 255 gives **255**.

(You can't actually reach either limit in a 20-cycle game that starts at 50,
but your design should still handle them.)

### 5. Winner output (combinational)
```
if (cycle < 20)                -> winner_ID = 3   // game in progress
else if (points1 > points2)    -> winner_ID = 1
else if (points1 < points2)    -> winner_ID = 2
else                           -> winner_ID = 3   // tie
```

### 6. Input assumptions
- `pos1` and `pos2` are always in the range 0–4, and they stay stable while the game runs.
- Behaviour for codes 5–7 is undefined and doesn't need to be handled.