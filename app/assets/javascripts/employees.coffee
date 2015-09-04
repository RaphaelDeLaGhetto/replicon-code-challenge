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

    $('.employee').click(hide_coworkers) 

#
# Click on an employee and hide his coworkers' schedules
#
hide_coworkers = (event) ->
    event.preventDefault()
    id = $(this).data('employee-id')

    if id is 'show-all' 
        $('.fc-event-container').children().show()
    else
        these = $('.fc-event-container > a:not(#' + id + ')')
        hide_coworkers = ->
            $(these).hide()
        $('.fc-event-container').children().show().promise().done(hide_coworkers)
