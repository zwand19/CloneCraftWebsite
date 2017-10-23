Clone Craft
=========================== 

This is a one verses one DOTA/StarCraft/Sims game.

Get Started
============
Prereqs: node, git, iis, mongodb

1. Run command prompt as Admin and navigate to directory
2. Pull Code with git
3. navigate to /Website
4. 'npm install grunt-cli -g'
5. 'npm install bower -g'
6. 'npm install'
7. Copy /config-sample.json to server/config.json
8. Open server/config.json and make sure the 'Server Directory' value is the directory that your site is in e.g. 'C:'
9. Have a mongo DB running under the connection string specified in config.json
10. Create an IIS site titled 'CloneCraft Tourney'
11. 'grunt server' will spin up the server
12. navigate to http://localhost:6108 in your browser and smoke test




Reference Architecture Documentation
===========================
* Built using the reference architecture [AngularFun](https://github.com/CaryLandholt/AngularFun)
*By [@CaryLandholt](https://twitter.com/carylandholt)*

Check out that project for full build instructions.