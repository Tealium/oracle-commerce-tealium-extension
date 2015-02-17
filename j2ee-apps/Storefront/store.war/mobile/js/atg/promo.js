CRSMA = window.CRSMA || {};

CRSMA.promo = function() {
  /*
   * Index of current selected Promo.
   * @private
   */
  var currentPromoIndex = 0;
 
  /**
   * Creates the "Promotional item" slider.
   * 
   * @private
   */
  var createPromotionalItemSlider = function(pGridId) {
    CRSMA.sliders.createSlider({
      gridid : pGridId,
      numberOfCells : 1,
      touchSensitivity : 6000,
      snapToGrid : true,
      extension : {
        /**
         * Calculates the middle cell based on the left position and do the
         * appropriate action.
         * 
         * @public
         */
        postTouchMove : {
          value : function(/* int */pLeft) {
            if (pLeft <= 0) {
              pLeft = (pLeft < 0) ? -pLeft : pLeft;
              var currentCell = Math.round(pLeft / this.colWidth);
              if (typeof this.currentCenterCell === "undefined") {
                this.currentCenterCell = currentCell;
                EventManager.publish("sliderMoveEvent", {
                  "caller" : "promo",
                  "focusedCellIndex" : currentCell
                });
                return;
              };
              if (this.currentCenterCell !== currentCell) {
                this.currentCenterCell = currentCell;
                EventManager.publish("sliderMoveEvent", {
                  "caller" : "promo",
                  "focusedCellIndex" : currentCell
                });
              }
            }
          }
        },

        /**
         * Calculates which items are on the screen, and set their display
         * to hidden.
         * 
         * @public
         */
        postTouchEnd : {
          value : function(/* int */pLeft, /* string */pDuration) {
            this.postTouchMove(pLeft);
            var sliderObject = this;
            var strippedDuration = pDuration.substring(0, pDuration.length - 1) * 1000;

            setTimeout(function() {
              if (!sliderObject.touching && pLeft <= 0) {
                pLeft = (pLeft < 0) ? -pLeft : pLeft;
                var cellsOffPage = Math.round(pLeft / sliderObject.colWidth);
                var end = cellsOffPage + 1;
                $.each(sliderObject.cells, function(index) {
                  var $cell = $(this);
                  if (index > cellsOffPage && index <= end) {
                    $cell.show();
                  }
                });
              }
            }, strippedDuration);
          }
        }
      }
    });
  };

  /*
   * Changes the class on the circle id to signify whether it's on or off.
   *
   * @param {string} pGridId
   *  Circle id.
   * @param {boolean} pStatus
   *  Indicator if circle is on.
   *  
   * @private
   */
  var setCircleStatus = function(pGridId, pStatus) {
    var $circleItem = $("#pageCircle_" + pGridId);
    var addClassValue = "BLANK";
    var removeClassValue = "ON";
    if (pStatus) {
      addClassValue = "ON";
      removeClassValue = "BLANK";
    }
    $circleItem.removeClass(removeClassValue).addClass(addClassValue);
  };

  /*
   * Handler for slider event.
   *
   * @param pEvent 
   *  Event object 
   * @param pParams
   * 
   * @private 
   */
  var sliderEventHandler = function(pEvent, pParams) {
    var caller = pParams.caller;
    var index = pParams.focusedCellIndex;
    if (caller === "promo") {
      setCircleStatus(index, true);
      setCircleStatus(currentPromoIndex, false);
      currentPromoIndex = index;
    }
  };

  /*
   * Event Manager object.
   * 
   * @namespace EventManager @public
   */
  var EventManager = {
    /*
     * Attaches handler to the specified event in the context of EventManager.
     * 
     * @param {string} event event name. @param fn function.
     * 
     * @public
     */
    subscribe : function(event, fn) {
      $(this).bind(event, fn);
    },
    /*
     * Executes handler, binded previously to the specified event with
     * parameters.
     * 
     * @param {string} event event name. @param params parameters to pass along
     * to the event handler.
     * 
     * @public
     */
    publish : function(event, params) {
      $(this).trigger(event, params);
    }
  };

  EventManager.subscribe("sliderMoveEvent", sliderEventHandler);
 
  /**
   * Displays promotional content item from the "sessionStorage".
   * 
   * @private
   */
  var displayPromotionalContentItems = function(pGridId) {
    var html = sessionStorage.getObject("promotionalContent");
    $(pGridId).empty().html(html);
    createPromotionalItemSlider(pGridId);
  };

  var initPromoSlider = function() {
    // Save the promotional content items and create the slider
    var html = $("#homeTopSlotContent").html();
    sessionStorage.removeItem("promotionalContent");
    sessionStorage.setObject("promotionalContent", html);
    createPromotionalItemSlider("#homeTopSlotContent");

    // Add this orientationchange/resize event to re-render the parents/child so
    // that things are centered correctly
    var orientationSupport = "onorientationchange" in window, orientationEvent = orientationSupport ? "orientationchange" : "resize";
    window.addEventListener(orientationEvent, function() {
      displayPromotionalContentItems("#homeTopSlotContent");
    }, false);
  };

  /**
   * "CRSMA.promo" public list
   */
  return {
    // Methods
    "initPromoSlider" : initPromoSlider
  }
}();