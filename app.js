//for autorestart
//require.paths.unshift(__dirname); //make local paths accessible
//require.NODE_PATH;

/**
 * Module dependencies.
 */

var express = require('express')
  , http = require('http')
  , dnode = require('dnode')
  ;
var app_loaded=false;

var routes = {};
routes.index = require('./routes/index.js')("test")

var app = express();

/* -> Expresss Config */

app.configure(function(){
  app.set('port', process.env.PORT || 3000);
  app.set('view engine', 'jade');

  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);

  app.use(require('less-middleware')({
      src: __dirname + '/public'
    , compress: true
  }));

  app.use(express.static(__dirname + '/public'));
  app.set('views', __dirname + '/views');
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

/* <- Expresss Config */

/* -> Routing*/

try {  

  app.get('/', routes.index);

} catch(e) {
  console.log(e.stack);
}

/* <- Routing*/


/* -> DNode */

dnode_server = dnode({
    init: function (bg_color, cb) {
      // app.render('index', {title: magento_confs[0].name + ' Sync' }, function(err, html){
      //    cb(html);
      // });
    }
});

/* <- DNode */

/* -> Servers */

var http_server = http.createServer(app);

dnode_server.listen(http_server);

http_server.listen(app.get('port'), '127.0.0.1', function() {
  console.log("Express server listening on port " + app.get('port'));
});

/* <- Servers */

/* -> Autostart*/

if(!app_loaded) {
  process.on('uncaughtException', function (err) {
    console.log('Caught exception: ' + err.stack);
  });
  app_loaded=true;
}

// exit if any js file or template file is changed.
// it is ok because this script encapsualated in a batch while(true);
// so it runs again after it exits.
var autoexit_watch = require('./autorestart.js');
var on_autoexit = function (filename) { } // if it returns false it means to ignore exit this time;  
autoexit_watch(__dirname,".js", on_autoexit);
//autoexit_watch(__dirname+"/templates",".html", on_autoexit);

/* <- Autostart*/