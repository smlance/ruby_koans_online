$(function () {
  var firstFail = $(".failed:first"),
      offset    = firstFail.offset(),
      top       = offset ? offset.top : 0;

  firstFail.find("input:first").focus();
  $("html,body").animate({scrollTop: top - 280}, 0);

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
  })
});
