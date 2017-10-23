### Command Object

***

The command object has 3 required properties

*commandName (string)*

Each command has a name to specify what action you are trying to take. Possible values include:

- attack
- build lesser
- build greater
- hand off
- mine
- move

*minionId (int)*

Required for minion commands (all commands except build). Specifies the id of the minion you are trying to manipulate. Set to null for build commands.

*params (object)*

Will contain extra parameters specific to each command.