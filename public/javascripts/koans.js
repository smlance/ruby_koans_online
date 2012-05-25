$(document).ready(function() {
  if($('#rotateTeam').length > 0){
    $('#rotateTeam').cycle({ fx: 'shuffle' });
  }

  $('.example form').submit(function(e) {
    var input = $(this).find('.koanInput').val(),
        koan = $(this).find('.koan'),
        error = $(this).find('.error');
    if (input === "true") {
      koan.removeClass('failed').addClass('passed');
      error.hide();
    } else {
      koan.removeClass('passed').addClass('failed');
      $(this).find('.error .given').text('<' + input + '>');
      error.show();
    }
    e.preventDefault();
  });


  var notAnExamplePage = !$('.example form').length;
  if(notAnExamplePage){
    var firstFail = $(".failed:first");
    firstFail.find("input:first").focus();

    var didPassFirst = $('.passed, .failed').eq(0).hasClass('passed');
    if(didPassFirst){
      var previousPassed = firstFail.prevAll('.passed').filter(':first');
      var scrollSpot = previousPassed.offset().top + previousPassed.height() - 5;
      window.scrollTo(0, scrollSpot);
    }
  }
});
