
var proofTab = {

    speed:300,
    containerWidth:$('.proof-panel').outerWidth(),
    containerHeight:$('.proof-panel').outerHeight(),
    tabWidth:$('.proof-tab').outerWidth(),

    init:function(){
        this.containerWidth = $('.proof-panel').outerWidth();
        this.containerHeight = $('.proof-panel').outerHeight();
        this.tabWidth = $('.proof-tab').outerWidth();
//        $('.proof-panel').css('height',proofTab.containerHeight + 'px');

        $('a.proof-tab').click(function(event){
            if ($('.proof-panel').hasClass('open')) {
                $('.proof-panel')
                .animate({left:'-' + proofTab.containerWidth}, proofTab.speed)
                .removeClass('open');
            } else {
                $('.proof-panel')
                .animate({left:'0'},  proofTab.speed)
                .addClass('open');
            }
            event.preventDefault();
        });
    }
};
var recommendTab = {

    speed:300,
    containerWidth:0,
    containerHeight:0,
    tabWidth:0,

    init:function(){
        this.containerWidth = $('.recommend-panel').outerWidth();
        this.containerHeight = $('.recommend-panel').outerHeight();
        this.tabWidth = $('.recommend-tab').outerWidth();
 //       $('.recommend-panel').css('height',recommendTab.containerHeight + 'px');
        $('a.recommend-tab').click(function(event){
            if ($('.recommend-panel').hasClass('open')) {
                $('.recommend-panel')
                .animate({left:'-' + recommendTab.containerWidth}, recommendTab.speed)
                .removeClass('open');
            } else {
                $('.recommend-panel')
                .animate({left:'0'},  recommendTab.speed)
                .addClass('open');
            }
            event.preventDefault();
        });
    }
};
function initButtons() {

$('input#proof_btn').click(function() {
        email = $("input#proof_email").val();
        about = window.location.href
        what = $("textarea#proof_what").val();
        sub = $('input#proof_sub').val();
        response_message = "&#1514;&#1493;&#1491;&#1492;&#32;&#1506;&#1500;&#32;&#1492;&#1492;&#1490;&#1492;&#1492;&#33;&#32;&#32;&#1504;&#1496;&#1508;&#1500;&#32;&#1489;&#1492;&#1511;&#1491;&#1501;&#46;"; // hardcoding the Hebrew because in context of a cp1255 page

        dataString = 'email=' + email + '&about=' + about + '&subscribe=' + sub + '&what=' + what;

        $.ajax({
          type: "POST",
          url: "http://bybeconv.benyehuda.org/proof",
          data: dataString,
          success: function() {
            $('#proof-form-wrap').html("<div id='response-message'></div>");
            $('#response-message').html("<p>" + response_message +"</p>")
            .hide()
            .fadeIn(500)
            .animate({opacity: 1.0}, 1000)
            .fadeIn(0, function(){
                $('.proof-panel')
                .animate({left:'-' + (proofTab.containerWidth)},
                (proofTab.speed))
                .removeClass('open');
            })
          }
        });
        return false;
    });

$('input#rec_btn').click(function() {
        email = $("input#recommend_email").val();
        what = $("textarea#rec_what").val();
        response_message = "&#1514;&#1493;&#1491;&#1492;&#32;&#1506;&#1500;&#32;&#1492;&#1492;&#1502;&#1500;&#1510;&#1492;&#33;"; // hardcoding the Hebrew because in context of a cp1255 page
        about = window.location.href
        sub = $('input#rec_sub').val();

        dataString = 'email=' + email + '&about=' + about + '&subscribe=' + sub + '&what=' + what;

        $.ajax({
          type: "POST",
          url: "http://bybeconv.benyehuda.org/recommendation",
          data: dataString,
          success: function() {
            $('#recommend-form-wrap').html("<div id='response-message'></div>");
            $('#response-message').html("<p>" + response_message +"</p>")
            .hide()
            .fadeIn(500)
            .animate({opacity: 1.0}, 1000)
            .fadeIn(0, function(){
                $('.recommend-panel')
                .animate({left:'-' + (recommendTab.containerWidth + recommendTab.tabWidth)},
                (recommendTab.speed))
                .removeClass('open');
            })
          }
        });
        return false;
    }
);

};

