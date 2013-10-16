// Generated by CoffeeScript 1.6.3
var Task, normalizeResults;

Task = require('../models/task');

normalizeResults = require('../lib/normalizer');

module.exports.all = function(req, res, next) {
  var options;
  options = {
    group: true
  };
  return Task.rawRequest('nbByDay', options, function(err, rows) {
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
      return res.send(results);
    }
  });
};
