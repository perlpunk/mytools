var months = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12
};

var notes;
function createOverview() {
    var notes_div = $('div.notes');
    notes = $(notes_div).find('tr.reply');
    if (notes.length == 0)
        return;

    var overview = $('<div id="thread_overview" >Navi</div>');
    $('body').append(overview);
    var first_author = $('#titlebar-top span.attribution a').text();
    var first = $('<div class="overview_posting" id="top_posting">'+first_author+'</div>');
    $(overview).append(first);
    $(first).click(function() {
        var title = $('#titlebar-top h3.other');
        $('html, body').animate({
            scrollTop: $(title).offset().top
        }, 500, null, function() { draw_outline() }
        );
    });
    var toggle_div = $('<div id="thread_overview_toggle_div" ></div>');
    var toggle_button = $('<span data-open="1" id="toggle_overview" style="padding: 5px;">&gt;&gt;</span>');

    $(toggle_div).append(toggle_button);
    $(toggle_button).click(function() { toggle_overview() });
    $('body').append(toggle_div);
    var outline = $('<div id="thread_overview_outline" />');
    $('#thread_overview').append(outline);


    var first_time = 0;
    var last_age = 0;
    for (var i=0; i<notes.length; i++) {
        var note = notes[i];
        var attr = $(note).find('span.attribution').last();
        var author = $(attr).find('a').text();
        var text = $(attr).contents().filter(
            function() {
                return this.nodeType == Node.TEXT_NODE;
            }
        );
        var datetext = text[1];
        var date = parsedate($(datetext).text());
        var sec = Math.floor(date.getTime()/1000);
        var age;
        if (i == 0) {
            first_time = sec;
            age = 0;
        }
        else {
            age = sec - first_time;
        }
        if (age > last_age)
            last_age = age;

        var posting = $('<div class="overview_posting" id="overview_' + i + '" data-age="'+age+'"/>');
        $(overview).append(posting);
        $(posting).text(author);
        var indents = $(note).find('ul.indent');
        var left = indents.length * 5;
        $(posting).css({"margin-left": left + 'px'});
        var f = createClickOverview(i);
        $(posting).click(f);
    }
    draw_outline();
    $(window).scroll(function() {
        draw_outline();
    });

    var step = last_age / 8;
    for (var i=0; i<notes.length; i++) {
        var posting = $('#overview_'+i);
        var age = $(posting).attr('data-age');
        var n = Math.floor(age / step);
        $(posting).addClass('age_'+n);
    }
}
$(document).ready(function() {
    createOverview();
});
function createClickOverview(i) {
    var f = function() {
        var note = notes[i];
        $('html, body').animate({
            scrollTop: $(note).offset().top
        }, 500, null, function() { draw_outline() }
        );
    };
    return f;
}

function parsedate(text) {
    if (text.match(/on (\w+) (\d{2}), (\d{4}) at (\d{2}):(\d{2})/)) {
        var monthtext = RegExp.$1;
        var month = months[monthtext];
        var day = RegExp.$2;
        var year = RegExp.$3;
        var hour = RegExp.$4;
        var minute = RegExp.$5;
        var d = new Date(year, month, day, hour, minute, 0, 0);
        return d;
    }

}

function toggle_overview() {
//    activate_overview();
    var toggle_button = $('#toggle_overview');
    var open = $(toggle_button).attr('data-open');
    var thread_navi_status = 0;
    if (open == 1) {
        thread_navi_status = 0;
        $(toggle_button).attr('data-open', 0);
        $('#thread_overview').animate({
            width: 'hide'
        }, 200);
        $(toggle_button).text('<<');
    }
    else {
        thread_navi_status = 1;
        $(toggle_button).attr('data-open', 1);
        $('#thread_overview').animate({
            width: 'show'
        },
        200, null, function() {
            draw_outline();
            $(toggle_button).text('>>');
        });
    }
    if (! localStorage)
        return;
    localStorage.setItem('poard_thread_navi_status', thread_navi_status);
}

function draw_outline() {
    var outline_top = 0;
    var outline_height = 0;
    var scrolltop = $(document).scrollTop();
    var scrollbottom = scrolltop + window.innerHeight;
    var overview_scrolltop = $('#thread_overview').scrollTop();
    for (var i = 0; i < notes.length; i++) {
        var note = notes[i];
        var top_offset = $(note).offset().top;
        if (scrolltop > top_offset) {
        }
        else if (outline_top == 0) {
            var overview_note = $('#overview_' + i);
            var f = overview_note.offset().top - $('#thread_overview').offset().top;
            outline_top = f;
            outline_top = f + overview_scrolltop;
        }
        else {
            if (scrollbottom < top_offset) {
                var overview_note = $('#overview_' + i);
                var f = overview_note.offset().top - $('#thread_overview').offset().top;
                var height = f - outline_top;
                outline_height = height + overview_scrolltop;
                break;
            }
        }
    }
    $('#thread_overview_outline').css({ top: outline_top + 'px'});
    if (outline_height == 0) {
        outline_height = $('#thread_overview').height() - outline_top + overview_scrolltop;
    }
    $('#thread_overview_outline').css({ height: outline_height-2 + 'px'});
}
