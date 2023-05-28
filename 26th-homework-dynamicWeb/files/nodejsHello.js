var http = require('http');
var port = 3000;
http.createServer(function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`<!DOCTYPE html>
<html>
    <head>
        <title>Hello Otus!</title>
    </head>
    <body>
       <h1>Hello Otus! It's NodeJS server</h1>
    </body>
</html> `);
}).listen(port);
