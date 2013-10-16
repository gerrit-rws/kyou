// Generated by CoffeeScript 1.6.3
var Mood, normalizeResults;

Mood = require('../models/mood');

normalizeResults = require('../lib/normalizer');

module.exports.all = function(req, res, next) {
  return Mood.rawRequest('statusByDay', function(err, rows) {
    var data, date, dateEpoch, results, value;
    if (err) {
      return next(err);
    } else {
      results = [];
      data = normalizeResults(rows);
      for (date in data) {
        value = data[date];
        dateEpoch = new Date(date).getTime() / 1000;
        results.push({
          x: dateEpoch,
          y: value
        });
      }
      return res.send(results, 200);
    }
  });
};

module.exports.today = function(req, res, next) {
  return Mood.loadTodayMood(function(err, mood) {
    if (err) {
      return next(err);
    } else if (mood != null) {
      return res.send(mood);
    } else {
      return res.send({});
    }
  });
};

module.exports.updateToday = function(req, res, next) {
  return Mood.loadTodayMood(function(err, mood) {
    var data;
    if (err) {
      return next(err);
    } else if (mood != null) {
      mood.status = req.body.status;
      return mood.save(function(err) {
        if (err) {
          return next(err);
        } else {
          return res.send(mood);
        }
      });
    } else {
      data = {
        status: req.body.status,
        date: new Date
      };
      return Mood.create(data, function(err, mood) {
        if (err) {
          return next(err);
        } else {
          return res.send(mood);
        }
      });
    }
  });
};
