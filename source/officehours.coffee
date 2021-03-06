define [
    'jquery',
    'underscore'
    'backbone'
], ($, _, Backbone) ->

  monday = (d) ->
    d = new Date d
    day = d.getDay()
    diff = d.getDate() - day + (if day == 0 then -6 else 1)
    new Date d.setDate diff

  class OfficeHours extends Backbone.Model
    start: null,

    url: ->
      if @start instanceof Date then "/oh/hours/#{encodeURIComponent @start}" else "/oh/hours/"

    initialize: (model, option) ->
      @start = monday(new Date)

  # This is going to go with the Google idea of a view and overlays:
  # given a parent object, and precise definitions of the base
  # Calendar, OfficeHours and Appointments views, draw 
    
  class Appointments extends Backbone.View
  
  class OfficeHoursView extends Backbone.View
    
  class DayView extends Backbone.View
    
      
  class CalendarView extends Backbone.View
    className: 'calendar'
    
    events:
      'click .forward': "nextWeek"
      'click .backward': "lastWeek"

    initialize: (options) ->

  ->
    officehours = new OfficeHours()
    $.when(officehours.fetch()).then(console.log(officehours))
