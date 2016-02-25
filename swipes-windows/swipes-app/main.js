
var app = require('app');  // Module to control application life.
var BrowserWindow = require('browser-window');  // Module to create native browser window.
var Menu = require('menu');
var Tray = require('tray');
var ipc = require('ipc');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;
var appIcon = null;
var isQuitting = false;

var onTrayDoubleTap = function(bounds) {
  	mainWindow.show();
};

var showMainWindow = function(show) {
	if (mainWindow) {
		if (show)
			mainWindow.show();
		else
			mainWindow.hide();
	}
}

// var isRunningElectron = function() {
// 	return process && process.versions['electron'] ? true : false;
// };
//
// console.log('isRunningElectron: ' + isRunningElectron());

app.on('ready', function() {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 900, height: 700, title: 'Swipes'});

  mainWindow.setMenu(null);

  // and load the index.html of the app.
  //mainWindow.loadUrl('file://' + __dirname + '/index_not_used.html');
  mainWindow.loadUrl('http://team.swipesapp.com/');
  //mainWindow.loadUrl('http://localhost:9000/');

  // Open the devtools.
  //mainWindow.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    //console.log('quiting on closed');
    mainWindow = null;
  });

  mainWindow.on('close', function(event) {
      if (isQuitting == false) {
        //   console.log('hiding');
          mainWindow.hide();
          event.preventDefault();
      }
    //   else {
    //       console.log('quiting');
    //   }
  });

  // tray stuff
  var iconPath = __dirname + '/tray.png';
  var iconEventPath = __dirname + '/tray-event.png';
  appIcon = new Tray(iconPath);
  var contextMenu = Menu.buildFromTemplate([
    { label: 'Show', type: 'normal', click: function() {
    	onTrayDoubleTap();
    }},
    { label: '-', type: 'separator' },
    { label: 'Quit', type: 'normal', click: function() {
        isQuitting = true;
        app.quit();
        appIcon.destroy();
    } },
  ]);
  appIcon.setToolTip('Swipes');
  appIcon.setContextMenu(contextMenu);
  appIcon.on('double-clicked', function(event, bounds) {
      onTrayDoubleTap(bounds);
  });

  mainWindow.on('focus', function(event) {
      appIcon.setImage(iconPath);
  });

  // IPC
  ipc.on('newEvent', function(event, arg) {
      // console.log('IPC async: ' + arg);
      // event.sender.send('asynchronous-reply', 'data');
    if (!mainWindow.isFocused()) {
        appIcon.setImage(iconEventPath);
    }
  });

  ipc.on('slack_login', function(event, arg) {
    //    console.log(arg);
       mainWindow.webContents.send('slack_login', arg);
  });

});

app.on('activate-with-no-open-windows', function() {
	if (mainWindow)
		showMainWindow(true);
});

app.on('window-all-closed', function() {
    if (isQuitting) {
        console.log("window-all-closed")
        app.quit();
    }
});
