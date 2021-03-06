// Generated by CoffeeScript 1.10.0
var dailynotes, moods, trackers;

moods = require('./moods');

dailynotes = require('./dailynotes');

trackers = require('./trackers');

module.exports = {
  'slug': {
    param: trackers.loadMetadataTracker
  },
  'trackerId': {
    param: trackers.loadTracker
  },
  'trackerAmountId': {
    param: trackers.loadTrackerAmount
  },
  'day': {
    param: trackers.loadDay
  },
  'all-data': {
    get: trackers.allData
  },
  'moods/mood/:day': {
    get: moods.day,
    put: moods.updateDay
  },
  'moods/export/mood.csv': {
    get: moods["export"]
  },
  'moods/:startDate/:endDate': {
    get: moods.all
  },
  'basic-trackers': {
    get: trackers.allBasicTrackers
  },
  'basic-trackers/export/:slug.csv': {
    get: trackers["export"]
  },
  'trackers/export/:trackerId/export.csv': {
    get: trackers.rawDataCsv
  },
  'metadata/basic-trackers/:slug': {
    get: trackers.getMetadata,
    put: trackers.updateMetadataBasic
  },
  'trackers': {
    get: trackers.all,
    post: trackers.create
  },
  'trackers/:trackerId': {
    put: trackers.update,
    del: trackers.destroy
  },
  'trackers/:trackerId/csv': {
    get: trackers.rawDataCsv,
    post: trackers["import"]
  },
  'trackers/:trackerId/raw-data': {
    get: trackers.rawData
  },
  'trackers/:trackerId/raw-data/:trackerAmountId': {
    del: trackers.rawDataDelete
  },
  'trackers/:trackerId/day/:day': {
    get: trackers.day,
    put: trackers.updateDayValue
  },
  'trackers/:trackerId/amounts/:startDate/:endDate': {
    get: trackers.amounts
  },
  'dailynotes/:day': {
    get: dailynotes.day,
    put: dailynotes.updateDay
  },
  'dailynotes/': {
    get: dailynotes.all
  }
};
