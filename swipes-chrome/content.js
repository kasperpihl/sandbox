(function () {

  if (window.top !== window.top || /\.xml$/.test(window.location.pathname)) {
    return;
  }

  // note/url separator
  var nL = " ... \n";

  // trims whitespace, reduces inner newlines and spaces
  // and keeps string below 500 chars
  function trim (string, length) {

    // default length to trim by is 500 chars
    length = length || 500;

    // get rid of stacked newlines
    string = (string || '').replace(/\n{3,}/g, '\n\n');

    // get rid of redonk spaces
    string = string.replace(/\s{3,}/g, ' ');
    string = $.trim(string);

    // only trim string length if it's
    if (string.length > length) {
      string = string.substring(0, length) + '...';
    }

    return string;
  }

  function fetchOpenGraph () {

    var data = {};

    data.url = $('meta[name="og:url"]').attr('content') || $('meta[property="og:url"]').attr('content');
    data.title = $('meta[name="og:title"]').attr('content') || $('meta[property="og:title"]').attr('content');
    data.description = $('meta[name="og:description"]').attr('content') || $('meta[property="og:description"]').attr('content');

    return data;
  }

  function fetchTwitterCard () {

    var data = {};

    data.url = $('meta[name="twitter:url"]').attr('content');
    data.title = $('meta[name="twitter:title"]').attr('content');
    data.description = $('meta[name="twitter:description"]').attr('content');

    return data;
  }

  // get the datas we really want
  var Scrapers = {

    'gmail': function  () {

      var data = {};

      data.scraper = 'gmail';
      data.title = window.title;
      data.url = window.location.href;

      var note = '';

      $('.ii').each(function (index, element) {

        var text = $(element).text();

        if (!text) {
          return;
        }

        if (note) {
          note = note + '\n\n';
        }

        note = note + text;
      });

      data.note = note;

      return data;
    },

    'outlook': function  () {

      var data = {};

      data.scraper = 'outlook';
      data.title = $('.ReadMsgSubject').not('style, textarea').text();
      data.url = 'none';
      data.note = $('.ReadMsgBody *').not('style, textarea, .ExternalClass').text();

      return data;
    },

    'yahooMail': function  () {

      var data = {};

      var $titleClone = $('.info:visible > h3').clone();
      $titleClone.find('style').remove();

      var $msgClone = $('.msg-body.inner:visible').clone();
      $msgClone.find('style, script, meta').remove();

      data.scraper = 'yahooMail';
      data.title = $.trim($titleClone.text());
      data.url = 'none';
      data.note = $msgClone.text();

      return data;
    },

    'amazon': function  () {

      var data = {};

      data.scraper = 'amazon';

      data.title = $('meta[name="title"]').attr('content');
      var price = $('.priceLarge').text();

      if (price) {
        data.title = data.title + ' (' + price + ')';
      }

      data.url = $('link[rel="canonical"]').attr('href');
      data.note = $('meta[name="description"]').attr('content');
      data.specialList = 'wishlist';

      return data;
    },

    'imdb': function  () {

      var data = {};

      var stars = $.trim($('.star-box-giga-star').text());
      stars = stars.length ? ' [' + stars + ']' : '';

      data.scraper = 'imdb';
      data.title = $('h1 .itemprop').text();
      data.title = (data.title ? data.title + stars : undefined);
      data.url = $('link[rel="canonical"]').attr('href');

      data.note = $('p[itemprop="description"]').text();

      data.specialList = 'movies';

      return data;
    },

    'youtube': function  () {

      var data = {};
      var openGraph = fetchOpenGraph();

      data.scraper = 'youtube';
      data.title = openGraph.title;
      data.url = openGraph.url;
      data.note = openGraph.description;

      data.specialList = 'movies';

      return data;
    },

    'wikipedia': function  () {

      var data = {};

      data.scraper = 'wikipedia';

      var $noteSource = $('#mw-content-text').clone();
      $noteSource.find('.infobox').remove();

      data.title = document.title;
      data.url = window.location.href;
      data.note = $noteSource.text();
      data.specialList = 'readLater';

      data.note = data.note && data.note.replace(/\[\d+\]/g, '');

      return data;
    },

    'ebay': function () {

      var data = {};
      var openGraph = fetchOpenGraph();

      data.scraper = 'ebay';
      data.title = openGraph.title;
      data.url = openGraph.url;
      data.note = openGraph.description;
      data.specialList = 'wishlist';

      return data;
    },

    'asos': function () {

      var data = {};
      var openGraph = fetchOpenGraph();

      var isMarketplace = /marketplace\./.test(window.location.hostname);
      var mainDescription, careDescription, price;

      data.scraper = 'asos';
      data.title = openGraph.title;
      data.url = openGraph.url;

      if (isMarketplace) {
        price = $.trim($('.price-and-offer .price').text());
        mainDescription = $('#description-panel').html();
      }
      else {
        price = $.trim($('.product_price_details').text());
        mainDescription = $('.product-description').html();
        careDescription = $('#infoAndCare').html();
      }

      mainDescription = mainDescription && mainDescription.replace(/<br>/g, '\n').replace(/<(?:.|\n)*?>/gm, '');
      careDescription = careDescription && careDescription.replace(/<br>/g, '\n').replace(/<(?:.|\n)*?>/gm, '');

      if (price) {
        data.title = data.title + ' (' + price + ')';
      }
      data.note = $.trim(mainDescription + (careDescription ? '\n\n' + careDescription : ''));

      data.specialList = 'wishlist';

      return data;
    },

    'etsy': function () {

      var data = {};
      var openGraph = fetchOpenGraph();
      var price = $.trim($('.item-amount').first().text());
      data.scraper = 'etsy';
      data.title = ($('.title-module:visible').text() || openGraph.title);

      if (price) {
        data.title = data.title + ' (' + price + ')';
      }

      data.url = (openGraph.url || window.location.href);
      data.note = ($('.description-item:visible .description').text() || openGraph.description);
      data.specialList = 'wishlist';

      return data;
    },

    'hackerNews': function () {

      var data = {};

      data.scraper = 'hackerNews';
      data.title = window.title;
      data.url = window.location.href;

      var $bodyRow = $('.subtext').closest('tbody').find('tr').eq(3);
      var bodyText = $bodyRow.find('td').eq(1).text();

      if (bodyText) {
        data.note = bodyText;
      }

      data.specialList = 'readLater';

      return data;
    },

    'hackerNewsIndex': function (targetElement) {

      var data = {};

      var $element = $(targetElement);
      var $row = $element.closest('tr');
      var $titleRow = $row.prev('tr');
      var $title = $titleRow.find('.title').eq(1);

      data.title = $title.text();
      data.url = window.location.protocol + '//' + window.location.host + '/' + $element.find('a').last().attr('href');

      data.specialList = 'readLater';

      return data;
    },

    'twitterIndex': function (targetElement) {

      var data = {};

      var $element = $(targetElement);
      var $tweet = $element.closest('.content');

      data.title = $tweet.find('.js-tweet-text').text();
      data.url = window.location.protocol + '//' + window.location.host + $tweet.find('a.details').attr('href');

      return data;
    },

    'txt': function () {

      var data = {};

      data.title = window.location.href;
      data.url = window.location.href;
      data.note = document.childNodes[0].innerText || document.childNodes[0].textContent;

      return data;
    },

   'yelp': function () {

      var data = {};
      var note = '';

      // build the address url
      var address = '';
      $('#bizInfoContent address *').each(function (index, element) {

        var text = $.trim($(element).text());
        if (text) {
          if (address) {
            address += ', ';
          }
          address += text;
        }
      });

      if (address) {
        note += 'https://maps.google.com/maps?z16&q=' + encodeURIComponent(address) + '\n';
      }

      // add the phone number
      var phone = $.trim($('#bizPhone').text());
      if (phone) {
        note += phone + '\n';
      }

      // add the business' url
      var bizUrl = $.trim($('#bizUrl a').text());
      if (bizUrl) {
        note += bizUrl + '\n';
      }

      data.title = $.trim($('#bizInfoHeader h1').text());

      // find the description
      $('head meta').each(function (index, element) {
        if ($(element).attr('property') === 'og:description') {
          data.title += ' - ' + $(element).attr('content');
        }
      });

      // find the rating
      $('#bizRating .rating meta').each(function (index, element) {
        if ($(element).attr('itemprop') === 'ratingValue') {
          data.title += ' [' + $(element).attr('content') + ']';
        }
      });

      data.note = note + '\n';
      data.scraper = 'yelp';
      data.url = window.location.href;

      return data;
    },

    'tripadvisor': function () {

      var data = {};

      data.title = $.trim($('h1').first().text());
      var replaceTitle = data.title + ':';

      var note = $.trim($('meta[name="description"]').attr('content').replace(replaceTitle, '')) + '\n\n';

      // build the address url
      var address = '';
      $('.infoBox address *').each(function (index, element) {

        var text = $.trim($(element).text());

        if (text && address.indexOf(text) < 0) {

          if (address) {
            address += ', ';
          }

          address += text;
        }
      });

      if (address) {
        note += 'https://maps.google.com/maps?z16&q=' + encodeURIComponent(address) + '\n';
      }

      data.note = note;
      data.scraper = 'tripadvisor';
      data.url = window.location.href;
      data.specialList = 'wishlist';

      return data;
    }
  };

  // scrape something based on the current url
  function scrape (data) {

    var hash = window.location.hash;
    var host = window.location.hostname;
    var path = window.location.pathname;
    var search = window.location.search;

    console.debug(hash, host, path, search);

    var scraped;

    if (/\.txt/.test(path)) {
      scraped = Scrapers.txt();
    }
    else if (/mail\.google\.com/.test(host) && hash.split('/')[1]) {
      scraped = Scrapers.gmail();
    }
    else if (/mail\.live\.com/.test(host) && (/&mid=/.test(hash) || /&mid=/.test(search))) {
      scraped = Scrapers.outlook();
    }
    else if (/mail\.yahoo\.com/.test(host)) {
      scraped = Scrapers.yahooMail();
    }
    else if (/amazon\./.test(host)) {
      scraped = Scrapers.amazon();
    }
    else if (/imdb\./.test(host)) {
      scraped = Scrapers.imdb();
    }
    else if (/youtube\.com/.test(host)) {
      scraped = Scrapers.youtube();
    }
    else if (/wikipedia\.org/.test(host)) {
      scraped = Scrapers.wikipedia();
    }
    else if (/ebay\./.test(host)) {
      scraped = Scrapers.ebay();
    }
    else if (/\.asos\./.test(host)) {
      scraped = Scrapers.asos();
    }
    else if (/\.etsy\./.test(host)) {
      scraped = Scrapers.etsy();
    }
    else if (/news\.ycombinator\.com/.test(host) && path === '/item') {
      scraped = Scrapers.hackerNews();
    }
    // else if (/news\.ycombinator\.com/.test(host) && data.scraperTarget) {
    //   scraped = Scrapers.hackerNewsIndex(data.scraperTarget);
    // }
    // else if (/twitter\.com/.test(host)) {
    //   scraped = Scrapers.twitterIndex(data.scraperTarget);
    // }
    else if (/\.yelp\.com/.test(host)) {
      scraped = Scrapers.yelp();
    }
    else if (/tripadvisor\./.test(host)) {
      scraped = Scrapers.tripadvisor();
    }

    // return something as nothing
    return buildData(scraped || {});
  }

  function buildData (scrapeData) {

    // fetch open graph and twitter card meta data
    var openGraph = fetchOpenGraph();
    var twitterCard = fetchTwitterCard();

    // build main meta datas - left priority
    var title = scrapeData.title || openGraph.title || twitterCard.title || document.title || '';
    var description = trim(openGraph.description || twitterCard.description || $('meta[name="description"]').attr('content') || '');
    var url = scrapeData.url || openGraph.url || twitterCard.url || $('link[rel="canonical"]').attr('href') || window.location.href;

    // if the url does not remotely resemble a fully qualified url, or start with a domain, or some other gibberesh, use location.href
    url = /^((.+)\:\/\/)?(.+(\.+).+)/.test(url) ? url : window.location.href;

    // start building note from passed in data
    // and make sure it doesn't exceed the max length
    var note = trim(scrapeData.note, 1000);

    // grab user selection and trim to max 5000 characters
    var selection = trim(window.getSelection().toString() || '', 5000);

    // if not passed in note data use a default note constructor
    if (!scrapeData.note) {
      // use selection over description if present
      // append url after description in note
      note = (selection ? selection : description);
    }
    else {
      // use selection over note if present and allow scraper exclude url
      note = (selection ? selection : note);
    }

    return {
      'title': $.trim(title),
      'note': $.trim(note),
      'url': url
    };
  }
  // listener for menu button
  chrome.extension.onConnect.addListener(function (rawPort) {
    var port = PortWrapper(rawPort);
    port.on('swipes_scrape', function (postData) {
      var scrapeData = scrape();
      port.emit('swipes_scraped_data', scrapeData);
      console.debug('content.js', scrapeData);
    });
  });
})();
