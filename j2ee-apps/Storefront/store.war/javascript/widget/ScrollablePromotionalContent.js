dojo.provide("atg.store.widget.ScrollablePromotionalContent");
dojo.require("dojox.fx.scroll");

dojo.declare(
  "atg.store.widget.ScrollablePromotionalContent",
  [dijit._Widget, dijit._Templated, dijit._Container],
  {
    debugOn: false,
    id: "",
    siteContextPath: "",
    previousLinkTitle: "previous",
    nextLinkTitle: "next",
    templatePath: dojo.moduleUrl("atg.store.widget", "template/scrollablePromotionalContent.html"),
    templateString: "",
    currentlyViewedItem: 0,
    previouslyViewedItem: 0,
    totalItems: 0,
    lastItem: 0,
    sliding: false,
    transitionEndEventName: null,
    
    //--------------------------------------------------------------------------
    // Startup
    //--------------------------------------------------------------------------
    
    /*
     * Override the dojo widget startup to create the navigation links and
     * indicator links.
     */
    startup: function() {
      console.debug("ScrollablePromotionalContent Startup"); 
      this.setNavigationLinks();
      this.setIndicatorLinks();
      
      // Cache the items
      var items = dojo.query(".carousel_inner .item", this.containerNode);
      if(items[0]){
        this.items = items;
      }

      // Handle image 404
      for(var i = 0; i < items.length; i++){
        var img = dojo.query("img", items[i])[0];
        if(img){
          dojo.connect(img, "onerror", function(element){
            this.onerror = "";
            this.src = "/crsdocroot/content/images/broken_image.jpg";
            return true;
          });
        }
      }
      
      // Cache the indicator div
      var indicators = dojo.query(".indicator li", this.containerNode);
      if(indicators[0]){
        this.indicators = indicators;
        dojo.addClass(this.indicators[this.currentlyViewedItem], "active");
      }
      
      // Set the index of our last item
      if(this.totalItems > 0){
        this.lastItem = this.totalItems - 1;
      }
      
      // Get the transition event name for this browser
      this.transitionEndEventName = this.getTransitionEndEventName();
      
      // FINALLY - when everything is ready display the widget
      dojo.style(this.wrapper, "display", "block");
    },

    
    //--------------------------------------------------------------------------
    // Indicator
    //--------------------------------------------------------------------------
    
    /*
     * Sets the indicator icons as links which navigate to its corresponding 
     * promotional content item.
     */
    setIndicatorLinks: function() {
      if(this.totalItems <= 1){
        return;
      }
      
      var self = this;
      var indicator = dojo.query(".indicator", this.containerNode)[0];
      
      // Get the data-indicator attribute and go to that corresponding item
      dojo.connect(indicator, "onclick", function(e){
        dojo.stopEvent(e);
        
        var value = dojo.attr(e.target, "data-indicator");
        if(value){
          self.jump(parseInt(value));
        }
      });
    },
    
    //--------------------------------------------------------------------------
    // Navigation Controls
    //--------------------------------------------------------------------------
        
    /*
     * Register the prev and next links only if we have multiple images.
     */
    setNavigationLinks: function() {
      if(this.totalItems <= 1){
        return;
      }
      
      var self = this;

      var prev = dojo.query(".prev_button .navlink a", this.containerNode);
      if(prev[0]){
        dojo.connect(prev[0], "onclick", function(e){
          dojo.stopEvent(e);       
          self.prev();
        });
      }

      var next = dojo.query(".next_button .navlink a", this.containerNode);
      if(next[0]){
        dojo.connect(next[0], "onclick", function(e){
          dojo.stopEvent(e);       
          self.next();
        });
      }  
    },
    
    //--------------------------------------------------------------------------
    // View Functions
    //--------------------------------------------------------------------------
    
    /*
     * View the previous item
     */
    prev: function() {
      if(this.sliding){
        return;
      }
      this.changeItemInView("prev", this.currentlyViewedItem - 1);
    },
    
    /*
     * View the next item 
     */
    next: function() {
      if(this.sliding){
        return;
      }
      this.changeItemInView("next", this.currentlyViewedItem + 1);
    },
    
    /*
     * Jump to the specified item
     */
    jump: function(id) {
      if(id == this.currentlyViewedItem
      || id < 0 || id > this.lastItem
      || this.sliding){
        return;
      }
      
      var type = (id > this.currentlyViewedItem ? 'next' : 'prev');
      this.changeItemInView(type, id);
    },
    
    /*
     * Change the currently viewed item using a smooth scroll effect.
     */
    changeItemInView: function(type, item) {
      this.sliding = true;
      this.setItemInView(item);
      
      console.debug("item " + this.currentlyViewedItem);
      
      var self = this;
      var direction = (type == 'next' ? 'left' : 'right');
      var next = this.items[this.currentlyViewedItem];
      var prev = this.items[this.previouslyViewedItem];
      
      // Move the requested image to the right
      dojo.addClass(next, type);
      next.offsetWidth; // 'force reflow', this is important
      
      // Transition out the active image
      dojo.addClass(prev, direction);
      
      // At the same time cycle in the new image. If CSS3 transitions are 
      // supported transition the image in, otherwise it will just appear.
      if(this.transitionEndEventName){
        var handle = dojo.connect(next, this.transitionEndEventName, function(e){
          dojo.disconnect(handle); // Don't fire on any other transitions
          resetStyles();
        });
        dojo.addClass(next, direction);
      }
      else{
        dojo.addClass(next, direction);
        resetStyles();
      }

      // Update indicators
      dojo.addClass(this.indicators[this.currentlyViewedItem], "active");
      dojo.removeClass(this.indicators[this.previouslyViewedItem], "active");
      
      /*
       * Reset the styles so the scrolling images are centered.
       */
      function resetStyles(){
        dojo.removeClass(prev, "active");
        dojo.addClass(next, "active");
        dojo.removeClass(prev, direction);
        dojo.removeClass(next, type);
        dojo.removeClass(next, direction);        
        self.sliding = false;
      }
    },
    
    /*
     * Maintain a record of the item we are currently viewing.
     */
    setItemInView: function (requestedItem) {
      // To the beginning
      if(requestedItem > this.lastItem){
        this.currentlyViewedItem = 0;
        this.previouslyViewedItem = this.lastItem;
        return;
      }
      
      // To the end
      if(requestedItem < 0){
        this.currentlyViewedItem = this.lastItem;
        this.previouslyViewedItem = 0;
        return;
      }
      
      // To the next or prev
      this.previouslyViewedItem = this.currentlyViewedItem;
      this.currentlyViewedItem = requestedItem;
    },
    
    //--------------------------------------------------------------------------
    // Utility Functions
    //--------------------------------------------------------------------------
       
    /*
     * Get the transitionend event name for this browser
     */    
    getTransitionEndEventName: function(){
      var i;
      var style = document.createElement('p').style;
      var transitions = {
        'transition':'transitionend',
        'OTransition':'oTransitionEnd',
        'MozTransition':'transitionend',
        'WebkitTransition':'webkitTransitionEnd'
      }

      for(i in transitions){
        if(style[i] !== undefined ){
          return transitions[i];
        }
      }
      
      return null;
  }

  })