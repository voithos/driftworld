# Ideas

Theme: Out of Control

## Brainstorm

- weapons constantly changing
  - 2d beat em up
  - bullet hell? bullet type keeps changing

- virus - control it or die

- strategy game with morale and mutiny elements
  - units can mutiny if they are grouped together (maybe if morale is low?)
  - units can disobey if morale is low
  - lose if base destroyed
  - mutiny can spontaneously appear?
  - oh basically like a cancer simulation :|

- [evangelion game] more damage you take, your "stability" decreases
  - [bad stuff happens]?
  - you are controlling something, thing has will of its own
  - if healthy (or some other marker) you're in control
  - once you start losing it, the machine is harder to control

- shape shifter with conservation of mass. can only get smaller, causing explosions?
  - platformer or metroidvania
  - enemies - can eat if small enough...?
  - or maybe can eat projectiles
  - gain mass, then explode

- stock market simulator?!
  - buy low, sell high, but people are crazy

- top-down shooter / fighter, but you can't control the character

- falling object, gaining momentum - basically chrome dinosaur game

## Chosen

Strategy game with morale elements

## Design

Open scale strategy game

- "Home Base", if destroyed, you lose
  - Creates 1 unit every N seconds
- "Base" - smaller, can be built at the cost of units
  - Creates 1 unit every M seconds
- "Tower" - has no morale, defends nearby stuff, can't move

Goal: destroy enemy home base

Units lose morale the further they are from a base
Units lose morale the longer they have been alive?
If morale goes to 0, units rebel (nearby units that have ~low morale also rebel)
Start disobeying and attacking nearby units. If no nearby units, march toward nearest base to attack it
