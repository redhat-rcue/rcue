(function($) {
  navlauncher = function () {
    // Keep the context menu open if an accordion header is clicked
    $('.dropdown.context').on({
      "click": function(event) {
        if($(event.target).attr('data-toggle') == 'collapse') {
          this.closable = false;
        } else {
          this.closable = true;
        }
      },
      "hide.bs.dropdown":  function() { 
        return this.closable;
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
    navlauncherpopovers();
  });
})(jQuery);