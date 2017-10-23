## Bot API

***

In order for your bot to be successfully uploaded and to compete in the tournaments, it must respond to the following requests:

**GET to /api/heartbeat** - REQUIRED. Used as a quick health check for the server. Any 200 response is acceptable

**OPTIONS to /api/heartbeat** - In order for the site to make requests to your AI running locally, you must enable CORS on your server by responding with a 200 to this

**GET to /** - Not required but may be handy for your own health checks.

**POST to /api/matchStart** - Not required but may be useful. During tournaments, this post is made to your bot before each match that you start. You may want to switch up your strategy each match if you are losing. Note that you can only be in one match at a time. Data posted:

+ **opponent_name:** name of the competitor you are facing. You could potentially hardcode strategies against certain opponents
+ **best_of:** number of games you will be playing in the match. Slightly misleading because it is not really a "Best of X" match, you will be playing the full amount of games every time
+ **game_ids:** an array of game id guids for the games that will be played in the match
+ **tournament_id:** guid of the tournament id

**POST to /api/gameResults** - Not required but may be useful. During tournaments, this post is made to your bot after each game you complete. You may want to switch up your strategy if your opponent is beating you. Data posted:

+ **won:** boolean indicating if you won the game
+ **match_over:** boolean indicating if this was the last game in the match
+ **id:** game id guid

**POST to /api/turn** - REQUIRED. The main function of your bot. Take in a game status object and return a list of commands.

**OPTIONS to /api/turn** - In order for the site to make requests to your AI running locally, you must enable CORS on your server by responding with a 200 to this