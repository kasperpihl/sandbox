var express = require('express');
var app = express();
var port = process.env.PORT || 3000;

app.use('/components', express.static('bower_components'));
app.use('/css', express.static('css'));
app.use('/img', express.static('img'));

app.get('/', function(req, res){
	res.sendfile('index.html');
});

app.listen(port);