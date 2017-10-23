## Testing Your AI

***

To test your AI you can play against it using the UI.  

To spin up your AI server, follow the instructions for the language you are developing in:

**C \#** - Open the solution and hit F5, it will run on port 3000

**Coffeescript/Javascript** - Open a command prompt and navigate to your AI directory. Type "npm install" to pull in dependencies. Type "node server.js PORT" where PORT is the port you want to run on

***

You can pit two of your own AIs against each other if you have two servers up and running on different ports.  
To do this, follow the instructions for the language you are developing in:

**C \#** - Open up two instances of your solution. Change the port in one of the projects by opening up the web project settings and go to Web -> Servers -> Specific Port

**Coffeescript/Javascript** - Open up two command prompts and navigate them both to your AI directory. Run "node server.js PORT" with two different ports

***

As part of your build process, you may want to open up a browser to start testing your game. You can pass in query params to https://codewars.geneca.com/#/CloneCraft/game to automatically start a game with your bot. You must pass in the type of each player, options include:

+ 'king': Play against the current king of the hill

+ 'human': A human competitor

+ 'ai': Your local bot

+ 'submitted': Your current submitted AI. You will need to be logged into the site for this to work

Pass these in as the params t1type and t2type for players one and two, respectively. You may also pass in team names if you wish with t1name and t2name. If you do not they will be assigned dynamically. For local bots, you must also pass in the port it is running on with t1port and/or t2port. Additionally, you may pass in fog=true or fog=false to set the "Show fog of war" setting

An example url is https://codewars.geneca.com/#/CloneCraft/game?t1type=human&t2type=ai&t2port=3000&t2name=iBot&fog=false