$(function () {
  var firstFail = $(".failed:first"),
      top       = firstFail.offset().top;

  firstFail.find("input:first").focus();
  $("html,body").animate({scrollTop: top - 280}, 0);
});
