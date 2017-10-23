## Starting Package

***

We have provided a starting set of code in each language so that you can focus entirely on creating your game AI.

Each of these packages creates an http service that can be called by your local game server.

Visit the downloads page to get your development package.

**The starting AI does the following:**

Builds a miner.

Navigates the miner to resources, mines them, and returns them to the base.

Builds attackers.

Wanders attackers randomly to the right.

If the attackers move next to the top left corner of the enemy base they attack it.

**Potential improvements include:**

Try and scout enemy base location

Store knowledge from previous turns

Mine the closest resource, not just a random one

Attack enemy minions

Attack the base from farther than one cell away

Build other types of minions

**Harder improvements include:**

Implement good pathfinding

Implement a gold hand-off system

Implement smart movement, don't move into enemy attack range

Program your AI to change strategies if you lose a game in a match