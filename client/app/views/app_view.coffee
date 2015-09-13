graphHelper = require '../lib/graph'
BaseView = require '../lib/base_view'

Tracker = require '../models/tracker'
MoodTrackerModel = require '../models/mood_tracker'
Zoom = require '../models/zoom'
DailyNote = require '../models/dailynote'
DailyNotes = require '../collections/dailynotes'

ZoomView = require './zoom'
MoodTracker = require './mood_tracker'
TrackerList = require './tracker_list'
BasicTrackerList = require './basic_tracker_list'
AddBasicTrackerList = require './add_basic_tracker_list'

RawDataTable = require './raw_data_table'

MainState = require '../main_state'

{DATE_FORMAT, DATE_URL_FORMAT} = require '../lib/constants'


module.exports = class AppView extends BaseView

    el: 'body.application'
    template: require('./templates/home')

    events:
        'change #datepicker': 'onDatePickerChanged'
        'blur #dailynote': 'onDailyNoteChanged'
        'click .date-previous': 'onPreviousClicked'
        'click .date-next': 'onNextClicked'
        'click .reload': 'onReloadClicked'
        'click #add-tracker-btn': 'onTrackerButtonClicked'
        'click #show-data-btn': 'onShowDataClicked'


    subscriptions:
        'start-date:change': 'onStartDateChanged'
        'end-date:change': 'onEndDateChanged'
        'tracker:removed': 'onTrackerRemoved'


    constructor: (options) ->
        super

        MainState ?= {}
        {startDate, endDate} = options
        @initDates startDate, endDate


    initDates: (startDate, endDate) ->

        if startDate
            MainState.startDate = moment startDate, DATE_URL_FORMAT
        else
            MainState.startDate = moment()
            MainState.startDate = MainState.startDate.subtract 'month', 6

        if endDate
            MainState.endDate = moment endDate, DATE_URL_FORMAT
        else
            MainState.endDate = moment()

        @currentDate = MainState.endDate


    getRenderData: =>
        return {
            startDate: MainState.startDate.format DATE_FORMAT
            endDate: MainState.endDate.format DATE_FORMAT
        }


    afterRender: ->
        @colors = {}
        @data = {}
        MainState.dataLoaded = false

        $(window).on 'resize',  @redrawCharts
        @initDatePickers()

        @addTrackerZone = @$ '#add-tracker-zone'
        @welcomeMessage = @$ '.welcome-message'

        #@rawDataTable = new RawDataTable()
        #@rawDataTable.render()
        #@$('#raw-data').append @rawDataTable.$el

        # Mood

        moodTracker = new MoodTrackerModel
            slug: 'mood'
            name: 'Mood'
            color: '#039BE5'
            metadata: {}
            description: """ The goal of this tracker is to help you
            understand what could influence your mood by comparing it to
            other trackers.
            """
        @moodTracker = new MoodTracker moodTracker
        @$('#mood-section').append @moodTracker.$el
        @moodTracker.render()


        # Trackers

        @trackerList = new TrackerList()
        @trackerList.render()
        @$('#content').append @trackerList.$el


        # Basic trackers
        #
        @basicTrackerList = new BasicTrackerList()
        @$('#content').append @basicTrackerList.$el
        @basicTrackerList.render()


        # Add tracker buttons

        @addBasicTrackerList = new AddBasicTrackerList(
            @basicTrackerList.collection)

        # Zoom widget

        zoom = new Zoom
        @zoomView = new ZoomView(
            zoom,
            @basicTrackerList.collection,
            @moodTracker.model,
            @trackerList.collection
        )
        @zoomView.render()
        @zoomView.hide()


    initDatePickers: ->
        now = new Date()
        $('#datepicker-start').pikaday
            maxDate: now
            format: DATE_FORMAT
            defaultDate: MainState.startDate.toDate()
            setDefaultDate: true
            onSelect: (value) ->
                Backbone.Mediator.publish 'start-date:change', value

        $('#datepicker-end').pikaday
            maxDate: now
            defaultDate: MainState.endDate.toDate()
            format: DATE_FORMAT
            onSelect: (value) ->
                Backbone.Mediator.publish 'end-date:change', value


    onStartDateChanged: (date) ->
        MainState.startDate = moment date
        @loadTrackers =>
            @zoomView.reload()
        @resetRouteHash()


    onEndDateChanged: (date) ->
        MainState.endDate = moment date
        @loadTrackers =>
            @zoomView.reload()
        @resetRouteHash()


    resetRouteHash: ->
        window.app.router.resetHash()


    onTrackerRemoved: (slug) ->
        @basicTrackerList.remove slug


    loadTrackers: (callback) ->
        MainState.dataLoaded = false
        @moodTracker.load =>
            @trackerList.load =>
                @basicTrackerList.load =>
                    MainState.dataLoaded = true
                    callback?()


    reloadAll: ->
        console.log 'start loading data'
        @moodTracker.reload =>
            console.log 'end loading data for mood'
            @basicTrackerList.reloadAll =>
                console.log 'end loading data'
        #@trackerList.reloadAll =>
            #if @$("#zoomtracker").is(":visible")
                #if @currentTracker is @moodTracker
                    #@currentData = @moodTracker.data
                #else
                    #tracker = @currentTracker
                    #trackerView = @basicTrackerList.views[tracker.cid]
                    #unless trackerView?
                        #trackerView = @trackerList.views[tracker.cid]
                    #@currentData = trackerView?.data
                #@onComparisonChanged()


    displayBasicTracker: (slug) ->
        MainState.currentView = "basic-trackers/#{slug}"
        @basicTrackerList.hide()
        @trackerList.hide()
        @addTrackerZone.hide()
        @moodTracker.hide()
        @welcomeMessage.hide()
        @displayZoomTracker slug, =>


    displayZoomTracker: (slug, callback) ->
        if MainState.dataLoaded
            @zoomView.show slug
            callback?()
        else
            @loadTrackers =>
                @zoomView.show slug
                callback?()


    displayTrackers: ->
        MainState.currentView = 'main'
        @basicTrackerList.show()
        @moodTracker.show()
        @addTrackerZone.show()
        @redrawCharts()
        @zoomView.hide()
        @loadTrackers() unless MainState.dataLoaded


    redrawCharts: =>
        $('.chart').html null
        $('.y-axis').html null

        if @$("#zoomtracker").is(":visible")
            @onComparisonChanged()

        else
            @moodTracker.redraw()
            #@trackerList.redrawAll()
            @basicTrackerList.redrawAll()

        true


    ## Note Widget

    onDailyNoteChanged: (event) ->
        text = @$("#dailynote").val()
        DailyNote.updateDay @currentDate, text, (err, mood) =>
            if err
                alert "An error occured while saving note of the day"


    loadNote: ->
        DailyNote.getDay @currentDate, (err, dailynote) =>
            if err
                alert "An error occured while retrieving daily note data"
            else if not dailynote?
                @$('#dailynote').val null
            else
                @$('#dailynote').val dailynote.get 'text'

        @notes = new DailyNotes
        @notes.fetch()


    ## Tracker creation widget

    onTrackerButtonClicked: ->
        name = $('#add-tracker-name').val()
        description = $('#add-tracker-description').val()
        alert name + description

        if name.length > 0
            @trackerList.collection.create(
                    name: name
                    description: description
                ,
                    success: ->
                    error: ->
                        alert 'A server error occured while saving your tracker'
            )


    ## Zoom widget
    #
    displayMood: ->
        MainState.currentView = "mood"
        @basicTrackerList.hide()
        @moodTracker.hide()
        @welcomeMessage.hide()
        @addTrackerZone.hide()
        @displayZoomTracker 'mood', =>


    displayTracker: (id) ->
        MainState.currentView = "mood"
        @basicTrackerList.hide()
        @trackerList.hide()
        @moodTracker.hide()
        @welcomeMessage.hide()
        @addTrackerZone.hide()
        @displayZoomTracker id


    onShowDataClicked: =>
        @rawDataTable.show()
        @rawDataTable.load @currentTracker

