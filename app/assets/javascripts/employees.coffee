# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
    $('#calendar').fullCalendar({
        defaultDate: moment($('#calendar').data('start-date')),
        header: {
            center: false,
            right: false,
        },
        events: $('#calendar').data('events'),
        eventRender: (event, element) ->
            element.attr('id', event.id);
        ,
    });
    console.log('hello', $('#calendar').data('events'));
