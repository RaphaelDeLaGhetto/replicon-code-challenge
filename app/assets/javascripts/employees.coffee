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

    $('.employee').click(toggle_coworkers) 

#
# Click on an employee and hide his coworkers' schedules
#
# @param string
#
toggle_coworkers = (event) ->
    event.preventDefault()
    these = $('.fc-event-container > a:not(#' + $(this).data('employee-id') + ')')
    hide_coworkers = ->
        $(these).hide()
    $('.fc-event-container').children().show().promise().done(hide_coworkers)

