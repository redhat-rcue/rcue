(function($) {
  navlauncher = function() {
    var documentHeight = $(window).height();
    var navigationHeight = $('.navigation').outerHeight();
    if (navigationHeight > documentHeight) {
      $('.offcanvas').children('div').css({ "min-height":navigationHeight});
    } else {
      $('.offcanvas').children('div').css({ "min-height": "100%"});
    }
  }
  navlauncheractive = function() {
    $(".nav-launcher-accordion .panel-body .nav > li > a").on('click', function () {
      $(".nav-launcher-accordion .panel-body .nav > li").removeClass('active');
      var siblingURL = $(this).attr('href');
      var selector = ".nav-launcher-accordion .panel-body .nav > li > a[href=\"" + siblingURL + "\"]";
      $(selector).parent('li').toggleClass('active');
    });
  }
  navlauncherbutton = function() {
    $('[data-toggle="offcanvas"]').click(function () {
      $('.offcanvas').toggleClass('active');
    });
  }
  navlauncherconfig = function() {
    $('#location').on('click', function () {
      if ($(this).is(":checked")) {
        $(".nav-launcher-accordion .panel-body .nav > li > a").attr('target','application');
      } else {
        $(".nav-launcher-accordion .panel-body .nav > li > a").attr('target','_blank');
      }
    });
  }
  navlauncherpopovers = function() {
    $('[data-toggle=popover]').popover({
      'delay': {"show": "1000", "hide": "0"},
      'html': 'true',
      'original-title': '',
      'placement': 'bottom',
      'toggle': 'popover',
      'trigger': 'hover'
    });
  }
  $(document).ready(function() {
    navlauncher();
    navlauncheractive();
    navlauncherbutton();
    navlauncherconfig();
    navlauncherpopovers();
  });
  $(window).resize(function() {
    navlauncher();
  });
})(jQuery);