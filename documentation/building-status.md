## Game Status Object

***

When it is your turn, the server will post you a (JSON) game status object. Your AI will take this object and decide the commands it wants to execute.  This object represents all information about your team, as well as any objects visible on the board

***

- base
    - id
    - health
    - gold
    - x
    - y
- board
    - height
    - width
- gameId
- minions *a list of all minions you own*
    - carrying *the amount of gold the minion has*
    - damage
    - health
    - id
    - mining
    - range *the minion's attack range*
    - speed
    - vision
    - x
    - y
- nextMinionId *if you issue a build minion command, this is the id it will be given*
- round *round of the game, a round consists of both teams issuing their commands*
- vision
    - bases *a list of all enemy bases in sight (max of 1)*
        - same properties as own base
    - minions *a list of all enemy minions in sight*
        - same properties as own minions
    - gold *a list of all gold in sight*
        - id
        - x
        - y

*example (Note: the names are not accurate e.g. its 'h' not 'health')* :
```javascript
{
    base: {
        id: 1,
        health: 94,
        gold: 140,
        x: 8,
        y: 24
    },
    board: {
        height: 30,
        width: 51
    },
	gameId: '2askld'
    minions: [
        {
            carrying: 0,
            damage: 2,
            health: 13,
            id: 2,
            mining: 30,
            range: 2,
            speed: 3,
            vision: 3
            x: 7,
            y: 23
        },
        {
            carrying: 10,
            damage: 2,
            health: 5,
            id: 4,
            mining: 100,
            range: 2,
            speed: 5,
            vision: 4
            x: 1,
            y: 23
        }
    ],
	nextMinionId: 64,
    round: 4,
    vision: {
        bases: [],
        minions: [
            {
                carrying: 0,
                damage: 7,
                health: 5,
                id: 4,
                mining: 10,
                range: 7,
                speed: 7,
                vision: 2
                x: 13,
                y: 26
            } 
        ],
        resources: [
            {
                id: 1,
                x: 0,
                y: 22
            },
            {
                id: 2,
                x: 0,
                y: 23
            },
            {
                id: 3,
                x: 0,
                y: 24
            },
            {
                id: 4,
                x: 0,
                y: 25
            }
        ]
    }
}
```