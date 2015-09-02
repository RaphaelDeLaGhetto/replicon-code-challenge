# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
    $('#calendar').fullCalendar({
        defaultDate: moment('2015-06-01'),
        header: {
            center: false,
            right: false,
        },
        events: $('#calendar').data('events'),
    });
    console.log('hello', $('#calendar').data('events'));
