// Generated by CoffeeScript 1.6.3
var Mood, americano, date_helpers;

americano = require('americano-cozy');

date_helpers = require('../lib/date');

module.exports = Mood = americano.getModel('Mood', {
  status: {
    type: String
  },
  date: {
    type: Date
  }
});

Mood.loadTodayMood = function(callback) {
  return Mood.request('byDay', {
    descending: true
  }, function(err, moods) {
    var date, mood, now;
    if (err) {
      return callback(err);
    } else if (moods.length !== 0) {
      mood = moods[0];
      now = date_helpers.getDateString(new Date);
      date = date_helpers.getDateString(mood.date);
      if (now === date) {
        mood.id = mood._id;
        return callback(null, mood);
      } else {
        return callback();
      }
    } else {
      return callback();
    }
  });
};
