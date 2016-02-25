(function(){
  var $addPage, $loadingPage, $loginPage, $successScreen;
  function initialize(){
    Parse.initialize("nf9lMphPOh3jZivxqQaMAg6YLtzlfvRjExUEKST3", "SEwaoJk0yUzW2DG8GgYwuqbeuBeGg51D1mTUlByg");
  };
  function start(){
    cacheElements();
    addHandlers();
    if(Parse.User.current()){
      showAdd();
      scrape();
    }
    else
      showLogin();
  }
  function cacheElements () {

    $addPage = $('.add-page');
    $loadingPage = $('.loading-page');
    $loginPage = $('.login-page');
    $successScreen = $('.success-page');
    
  }

  function showSuccess(){
    $successScreen.removeClass('hidden');
    $addPage.addClass('hidden');
    $loadingPage.addClass('hidden');
    $loginPage.addClass('hidden');
    setTimeout(function(){ 
      window.close(); 
    }, 2000);
  }

  function addHandlers(){
    // Login Click Handler
    $('.login-button').click(doLogin);
    $('.add-button').click(doAdd);
  }
  function showAdd (token) {

    $addPage.removeClass('hidden');
    $loadingPage.addClass('hidden');
    $loginPage.addClass('hidden');
  }
  function showLoading(loadMessage){
    $addPage.addClass('hidden');
    $('.loading-page .load-message').html(loadMessage);
    $loadingPage.removeClass('hidden');
    $loginPage.addClass('hidden');
  }
  function updateInputs(scrapedData){
    $('.title-input').val(scrapedData.title || '');
    $('.note-input').val(scrapedData.note || '');
    $('.url-input').val(scrapedData.url || '');
  }
  function showLoginErrorMessage(errorMessage){
    $('.login-error-message').removeClass('hidden');
    $('.login-error-message').html(errorMessage);
  }
  function showLogin () {
    $addPage.addClass('hidden');
    $loadingPage.addClass('hidden');
    $loginPage.removeClass('hidden');
  }
  function scrape () {

    chrome.tabs.query({
      'active': true,
      'currentWindow': true
    }, function (tabs){
      console.log("running scrape");
      var tab = tabs[0];
      var port = PortWrapper(chrome.tabs.connect(tab.id), {
        'name': 'swipes'
      });
      port.emit('swipes_scrape', {
        'tab': tab
      });
      port.on('swipes_scraped_data', function (scrapeData) {
        console.log("returned port on");
        console.log(scrapeData);
        updateInputs(scrapeData);
      });
    });
  }

  function responseFromSync(data){
    if (data && data.serverTime) {
      showSuccess();
    }
  }
  function errorFromSync(error){
    console.log(error);
  }
  function generateId(length) {
    var i, possible, text, _i;
    text = "";
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (i = _i = 0; 0 <= length ? _i <= length : _i >= length; i = 0 <= length ? ++_i : --_i) {
      text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
  }


  // Handle Adding
  function doAdd(){
    var title = $('.title-input').val();
    var notes = $('.note-input').val();
    var url = $('.url-input').val();
    var date = new Date().toISOString();
    var currentTime = {
      "__type": "Date",
      "iso": date
    }

    console.log($('.title-input').val());
    
    var todo = { "title": title, "notes":notes, "order": -1, "tempId": generateId(12), "schedule": currentTime };
    if (url){
      var urlAttachment = {"service":"url","identifier": url, "title":title};
      todo.attachments = [ urlAttachment ];
    }

    console.log(todo);
    showLoading("Adding to Swipes");
    url = "http://api.swipesapp.com/v1/sync";
    user = Parse.User.current();
    token = user.getSessionToken();
    data = {
      sessionToken: token,
      platform: "chrome-plugin",
      hasMoreToSave: true,
      version: 1,
      sendLogs: false,
      changesOnly: true
    };
    data.objects = {"ToDo":[todo],"Tag":[]};
    serData = JSON.stringify(data);
    settings = {
      url: url,
      type: 'POST',
      success: responseFromSync,
      error: errorFromSync,
      dataType: "json",
      contentType: "application/json; charset=utf-8",
      crossDomain: true,
      context: this,
      data: serData,
      processData: false
    };
    $.ajax(settings);
  }


  // Handle login
  function doLogin(){
    console.log("do login");
    var email = $("#email-field").val().toLowerCase();
    var password = $("#password-field").val();
      if (!validateFields(email, password)) {
        return;
      }
      showLoading("Logging in");
      Parse.User.logIn(email, password, {
        success: function() {
          showAdd();
          scrape();
          return;
        },
        error: function(user, error) {
          showLogin();
          showLoginErrorMessage("Wrong email or password");
          return console.log("error logging in");
        }
      });  
  }
  function validateFields(email, password) {
    if (!email) {
      showLoginErrorMessage("Please fill in your e-mail address");
      return false;
    }
    if (!password) {
      showLoginErrorMessage("Please fill in your password");
      return false;
    }
    if (email.length === 0 || password.length === 0) {
      showLoginErrorMessage("Please fill out both fields");
      return false;
    }
    if (!validateEmail(email)) {
      showLoginErrorMessage("Please use a real email address");
      return false;
    }
    return true;
  }
  function validateEmail(email) {
    var regex;
    regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return regex.test(email);
  }

  


  // Event listener for returned data
  chrome.runtime.onMessage.addListener(function (message, sender, callback) {
    console.log('returned onMessage listener');
    if (message.event === 'swipes_scraped_data') {
      
      console.log(message.data);
      updateInputs(message.data);
    }
  });
  document.addEventListener('DOMContentLoaded', start, false);
  
  initialize();
})();