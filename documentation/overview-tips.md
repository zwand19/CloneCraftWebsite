## FAQ/Pro Tips

***

Here is a list of important questions/answers and pro tips that cannot be found elsewhere in the documentation.

**Pro Tips**

- There is no maximum amount of commands you can send per turn.

- You can attack cells that your minion does not have vision of

- Commands are run by the game server in the order in which they are sent. The game status is updated after each command is run.
	
	- For example: you could move a minion 5 cells to the right and then issue a build command to its next cell to the right and it would be valid.
If you issued a build command next to the minion's old location it would fail.
	- Another example: you do not have enough gold to build a minion but you have a minion carrying gold who is about to return it to your base.
If you issue a build command first, it will fail. If you issue move commands to return the gold and then issue a build command, it would be valid.

- If your AI throws an exception or responds with invalid data then the game server will run your turn as if you issued no commands.

- All requests made will timeout in 1500 ms. (for debugging purposes, no timeout is set when you hit your AI while running from the browser, only when running tournaments)

**FAQ**

- Browser support: IE 10, newest version of Firefox, newest version of Chrome

- Site should look fine on tablets, although playing the game on a tablet has not been thoroughly tested