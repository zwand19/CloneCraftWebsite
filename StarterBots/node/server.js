//run 'node server' to start

require("coffee-script").register(); // allow node to require coffee files. run 'npm install' if this fails
var matchStarting = require("./engine/engine").matchStarting; // function to be called on match starting (turn)
var gameEnded = require("./engine/engine").gameResults; // function to be called game ended (turn)
var consumeTurn = require("./engine/engine").processGameStatus; // function to be called on new status (turn)

var newServer = function (turnFunction, matchStartFunction, gameOverFunction) {
    // Create a basic server
    if (typeof (turnFunction) != "function") {
        console.error("server.js requires a function to call on new turns! Aborting!");
        process.exit(1);
    }
    if (typeof (matchStartFunction) != "function") {
        console.error("server.js requires a function to call on end of matches! Aborting!");
        process.exit(1);
    }
    if (typeof (gameOverFunction) != "function") {
        console.error("server.js requires a function to call on games ending! Aborting!");
        process.exit(1);
    }

    // Port and IP
    process.env.ip = '127.0.0.1';
    process.env.port = process.argv[2]

    // reference the http module so we can create a webserver
    var http = require("http");
    var url = require("url");

    http.createServer(function (req, res) {
        var pathname = url.parse(req.url).pathname;
        if (pathname.toLowerCase() == "/api/turn") {
            if (req.method == 'POST') {
                handlePost(req, res, turnFunction, true);
            } else if (req.method == 'OPTIONS') {
                handleOptions(res);
            } else {
                handleInvalidRequest(res);
            }
        } else if (pathname.toLowerCase() == "/api/heartbeat") {
            if (req.method == 'GET') {
                handlePost(req, res, function() {return "Heart is beating!"}, true);
            } else if (req.method == 'OPTIONS') {
                handleOptions(res);
            } else {
                handleInvalidRequest(res);
            }
        } else if (pathname.toLowerCase() == "/api/gameresults") {
            if (req.method == 'POST') {
                handlePost(req, res, gameOverFunction, false);
            } else if (req.method == 'OPTIONS') {
                handleOptions(res);
            } else {
                handleInvalidRequest(res);
            }
        } else if (pathname.toLowerCase() == "/api/matchstart") {
            if (req.method == 'POST') {
                handlePost(req, res, matchStartFunction, false);
            } else if (req.method == 'OPTIONS') {
                handleOptions(res);
            } else {
                handleInvalidRequest(res);
            }
        } else {
            handleInvalidRequest(res);
        }
    }).listen(process.env.PORT, process.env.IP);

    console.log("Server listening at http://" + process.env.IP + ":" + process.env.PORT);

    function handlePost(req, res, f, sendResponse) {
        var fullBody = '';

        req.on('data', function (chunk) {
            // Append the current chunk of data to the fullBody variable
            fullBody += chunk.toString();
        });

        req.on('end', function () {
            // Parse the received body data
            var response = "";
            if (f !== null) response = f(fullBody);
            // Send a response back
            res.writeHead(200, { "Content-Type": "text/plain",
                                "Access-Control-Allow-Origin": "*",
                                "Access-Control-Allow-Methods": "POST",
                                "Access-Control-Allow-Headers": "Accept, Origin, Content-type"});
            if (sendResponse) res.write(response);
            res.end();
        });
    };

    function handleOptions(res) {
        // Send a response back
        res.writeHead(200, { "Content-Type": "text/plain",
                            "Access-Control-Allow-Origin": "*",
                            "Access-Control-Allow-Methods": "POST",
                            "Access-Control-Allow-Headers": "Accept, Origin, Content-type"});
        if (sendResponse) res.write("");
        res.end();
    }

    function handleInvalidRequest(res) {
        res.writeHead(200, { "Content-Type": "text/plain",
                            "Access-Control-Allow-Origin": "*",
                            "Access-Control-Allow-Methods": "POST",
                            "Access-Control-Allow-Headers": "Accept, Origin, Content-type"});
        res.write("Please post to /api/turn to run the engine");
        res.end();
    }
}

newServer(consumeTurn, matchStarting, gameEnded);