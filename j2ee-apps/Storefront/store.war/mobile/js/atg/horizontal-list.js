/**
 * Javascript functions used in productsHorizontaList.jsp.
 * 
 * @ignore
 */
CRSMA = window.CRSMA || {};

/**
 * @namespace "Products Horizontal List" Javascript module of "Commerce
 *            Reference Store Mobile Application"
 * @description Contains methods used in productsHorizontaList.jsp.
 */
CRSMA.horizontallist = function() {
  /**
   * the width of the cell in pixel
   */
  var cellWidth = 90;
  /**
   * This method initializes the sliders in productsHorizontalList.jsp.
   * 
   * @public
   */
  var createHorizontalListSliders = function() {
    // Set the width of itemContainer to the width of the entire screen.
    // The slider will then takes care of figuring out the appropriate width for the cells inside it.
    var doItemsExist = $(".itemsContainer").length > 0;
    if (doItemsExist) {
      var screenWidth = $(window).width() - 1;
      $(".itemsContainer").css({
        "width" : screenWidth
      });
    }

    var numberOfCells = Math.floor(screenWidth/cellWidth) + 0.5;
    // Initialize all sliders on the page
    $("div[id^='horizontalContainer']").each(function() {
      var id = $(this).attr("id");

      CRSMA.sliders.createSlider({
        gridid : "#" + id,
        numberOfCells : numberOfCells,
        paginated: true,
        onTouchEventException : function(el) {
          $(el).css({
            "height" : "70px",
            "overflow" : "auto"
          });
        }
      });

      // Mark items that are off screen as hidden so that VoiceOver won't read them (accessibility)
      var $cells = $(this).children(".cell");
      $cells.each(function(index) {
        if (index >= numberOfCells) {
          $(this).css({
            display : "none"
          });
        } else{
          $(this).css({
            display : ""
          });
        }
      });
    });

    // Now that the slider has been initialized, let itemContainer inherits its parent's width.
    // This will let the browser figure out the right value when the user switches between portrait and landscape views
    if (doItemsExist) {
      $(".itemsContainer").css({
        "width" : "inherit"
      });
    }
  };
  var displayHorizontalListSliders = function() {
    // Populate slider divs with the content
    $("div[id^='horizontalContainer']").each(function() {
      var id = $(this).attr("id");
      var html = sessionStorage.getObject(id);
      $(id).empty().html(html);
    });
    createHorizontalListSliders();
  }
  var initHorizontalListSliders = function() {
    // Save the content of sliders in session object to retrieve when screen orientation changes
    $("div[id^='horizontalContainer']").each(function() {
      var id = $(this).attr("id");
      var html = $(id).html();
      sessionStorage.removeItem(id);
      sessionStorage.setObject(id, html);
    });
    createHorizontalListSliders();
    // Add this orientationchange/resize event to re-render the sliders so that things are centered correctly
    var orientationSupport = "onorientationchange" in window, orientationEvent = orientationSupport ? "orientationchange" : "resize";
    window.addEventListener(orientationEvent, function() {
      displayHorizontalListSliders();
    }, false);
  };

  /**
   * List of public "CRSMA.horizontallist" methods
   */
  return {
    // methods
    'initHorizontalListSliders' : initHorizontalListSliders
  }
}();
