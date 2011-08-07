#!/usr/bin/env node

var consumerKey = "";
var consumerKeySecret = "";

var ntwitter = require('ntwitter');
var sqlite3 = require('sqlite3');

var db = new sqlite3.Database('../db/development.sqlite3');

function tweetAll() {
  db.each('select * from users', {}, function (err, row) {
    if (!!err) { return; } // forget error
    console.log("retrieved row: ", row);

    var twit = new ntwitter({
      consumer_key: consumerKey,
      consumer_secret: consumerKeySecret,
      access_token_key: row.access_token,
      access_token_secret: row.access_token_secret
    });
    twit.verifyCredentials(function (err, data) {
      if (!!err) {
        console.log("authentication failed: user: ", row.screen_name);
        return;
      }
      var matched = row.birthday.match(/^(\d{4}-\d{2}-\d{2}$/);
      if (!matched) {
        console.log("malformed birthday: user: ", row.screen_name);
        return;
      }
      var tweet = generateTweet(
        row.screen_name,
        new Date(matched[1], matched[2], matched[3])
      );
      tweet += ' #意識低い';
      twit.updateStatus(tweet, function (err, data) {
        if (!!err) {
          console.log("updating status failed: user: ", row.screen_name);
        }
      })
    });
  });
}

function generateTweet(name, birthday) {
  function irand(max) {
    return Math.floor(Math.random() * (max + 1));
  }
  var livedays = Math.floor(((new Date()) - birthday) / (86400 * 1000));
  var restdays = 30000 - livedays;
  var tmpls = [
    ':user:は:lived:日生きた。人生あと:rest:日あるしまあ余裕',
    ':user:は:lived:日生きた。まだイケるイケる',
    ':user:は:lived:日生きた。人生あと:rest:日。明日から本気出す'
  ];
  var tmpl = tmpls[irand(tmpls.length - 1)];
  if (livedays < 0) {
    tmpl = ':user:は:lived:日生きた．こいつ、未来に生きてやがる……ッ!!';
  } else if (livedays == 0) {
    tmpl = ':user:は今まさに生まれた。Hello, World!';
  } else if (restdays <= 0) {
    tmpl = ':user:は:lived:日生きた。お前はもう死んでいる';
  }
  return tmpl.replace(':lived:', livedays)
    .replace(':rest:', restdays)
    .replace(':user:', '@' + name);
}

require('daemon').daemonize('../neg30d.log', '../tmp/neg30d.pid', function (err, pid) {
  if (!!err) {
    console.log("daemonize failed");
    return;
  }

  var now = new Date();
  var delay = (23 - now.getHours()) * 3600;
  setTimeout(function () {
    setInterval(tweetAll, 24 * 3600 * 1000);
  }, delay * 1000);

  console.log("daemon started; pid: ", pid);
  console.log("first posting will start after " + delay + " sec");
});
