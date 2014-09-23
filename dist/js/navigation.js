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
    $(".nav-launcher-accordion .panel-body .nav li a").on('click', function () {
      $(".nav-launcher-accordion .panel-body .nav li").removeClass('active');
      var siblingURL = $(this).attr('href');
      var selector = ".nav-launcher-accordion .panel-body .nav li a[href=\"" + siblingURL + "\"]";
      $(selector).parent('li').toggleClass('active');
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
  navlaunchertoggle = function() {
    $('.nav-launcher-toggle').on("click", function() {
      var el = $(this);
      if (el.text() == el.data("text-swap")) {
        el.text(el.data("text-original"));
      } else {
        el.data("text-original", el.text());
        el.text(el.data("text-swap"));
      };
      $('.panel-hidden, .panel-show').toggle();
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
  $(document).ready(function() {
    navlauncher();
    navlauncheractive();
    navlauncherpopovers();
    navlaunchersearch();
    navlaunchertoggle();
  });
  $(window).resize(function() {
    navlauncher();
  });
})(jQuery);