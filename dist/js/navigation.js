(function($) {
  navlauncher = function() {
    var documentHeight = $(window).height();
    var navigationHeight = $('.navigation').outerHeight();
    // console.log('documentHeight =' + documentHeight);
    // console.log('navigationHeight = ' + navigationHeight);
    if (navigationHeight > documentHeight) {
      $('.offcanvas').children('div').css({ "min-height":navigationHeight});
    } else {
      $('.offcanvas').children('div').css({ "min-height": "100%"});
    }
  }
  navlauncheractive = function() {
    $(".nav-launcher-accordion .panel-body .nav li").on('click', function () {
      $(".nav-launcher-accordion .panel-body .nav li").removeClass('active');
      var siblingURL = $(this).children('a').attr('href');
      var selector = ".nav-launcher-accordion .panel-body .nav li a[href=\"" + siblingURL + "\"]";
      $(selector).parent('li').toggleClass('active');
    });
  }
  navlaunchersearch = function() {
    // Initialize Boostrap-select
    $('.selectpicker').selectpicker();
    // Hide the clear button
    $(".search-pf .clear").hide($(this).prev('input').val());
    // Show the clear button upon entering text in the search input
    $(".search-pf .has-clear .form-control").keyup(function () {
      var t = $(this);
      t.next('button').toggle(Boolean(t.val()));
    });
    // Upon clicking the clear button, empty the entered text and hide the clear button
    $(".search-pf .clear").click(function () {
      $(this).prev('input').val('').focus();
      $(this).hide();
    });
  }
  navlauncherpopovers = function() {
    //PatternFly.popovers('[data-toggle=popover]');
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
    navlaunchersearch();
    navlauncherpopovers();
  });
  $(window).resize(function() {
    navlauncher();
  });
})(jQuery);