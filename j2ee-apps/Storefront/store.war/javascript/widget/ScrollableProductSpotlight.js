dojo.provide("atg.store.widget.ScrollableProductSpotlight");
dojo.require("dojox.fx.scroll");

dojo.declare(
  "atg.store.widget.ScrollableProductSpotlight",
  [dijit._Widget, dijit._Templated, dijit._Container],
  {
    debugOn: false,
    id: "",
    totalProducts: 0,
    previousLinkTitle: "previous",
    nextLinkTitle: "next",
    productsPerPage: 5,
    templatePath: dojo.moduleUrl("atg.store.widget", "template/scrollableProductSpotlight.html"),
    templateString: "",
    totalPages: 1,
    currentPage: 0,
    previousPage: 0,
    sliding: false,
    transitionEndEventName: null,
    pages: null,
		
    //--------------------------------------------------------------------------
    // Startup
    //--------------------------------------------------------------------------
		
    /*
     * Overridden widget startup function  to add ids to the product li 
     * elements, set the total number of pages to navigate through and create
     * navigation links.
     */
    startup: function() {
      console.debug("ScrollableProductSpotlight startup");
 
      this.setPages();      
      this.setNavigationLinks();
           
      // Set the active page
      dojo.addClass(this.pages[this.currentPage], "active");
      
      // Get the transition event name for this browser
      this.transitionEndEventName = this.getTransitionEndEventName();
      
      // FINALLY - when everything is ready display the widget
      dojo.style(this.wrapper, "display", "block");
    },
    
    /*
     * Sets the total number of pages for this widget and groups the paged items
     * inside a div.
     */
    setPages: function(){
      if(this.totalProducts > this.productsPerPage){
        var pages = this.totalProducts/this.productsPerPage;
        this.totalPages = Math.ceil(pages);
      }
      
      var root = dojo.query(".carousel_inner", this.containerNode);

      this.pages = [];
      
      // Create page divs
      for(var i = 0; i < this.totalPages; i++){
        this.pages[i] = dojo.create("div", {"class": "item"}, root[0]);
      }
      
      // Group products inside the divs
      var products = dojo.query("div.product", root[0]);
      var pageCount = 0;
      for(var i = 0; i < products.length; i++){
        dojo.place(products[i], this.pages[Math.floor(i/this.productsPerPage)]);
      }
      
      // Cache the page display div
      var pageNode = dojo.query(".navigation .pageNum", this.containerNode);
      if(pageNode[0]){
        this.pageNode = pageNode[0];
      }
    },

    //--------------------------------------------------------------------------
    // Product View Functions
    //--------------------------------------------------------------------------

    /*
     * View the previous item
     */
    prev: function() {
      if(this.sliding){
        return;
      }
      this.changePage("prev", this.currentPage - 1);
    },
    
    /*
     * View the next item 
     */
    next: function() {
      if(this.sliding){
        return;
      }
      this.changePage("next", this.currentPage + 1);
    },

    //--------------------------------------------------------------------------
    // Navigation Link Functions
    //--------------------------------------------------------------------------
    
    /*
     * 
     */
    setPageDisplay: function(){
      // Take account of the zero index array
      this.pageNode.innerHTML = (this.currentPage +1) + "/" + this.totalPages;
    },
		
    /*
     * Attach the prev and next events only if we have multiple pages.
     */
    setNavigationLinks: function(){
      if(this.totalPages <= 1){
        return;
      }
      
      var self = this;

      this.setPageDisplay();
      
      var prev = dojo.query(".control.previous", this.containerNode);
      if(prev[0]){
        dojo.connect(prev[0], "onclick", function(e){
          dojo.stopEvent(e);
          self.prev();
        });
      }
      
      var next = dojo.query(".control.next", this.containerNode);
      if(next[0]){
        dojo.connect(next[0], "onclick", function(e){
          dojo.stopEvent(e);
          self.next();
        });
      }
    },
		
    /*
     * Change the current page
     */    
    changePage: function(type, page) {
      this.sliding = true;
      
      if(page > this.totalPages -1){
        this.currentPage = 0;
        this.previousPage = this.totalPages - 1;
      }
      else if(page < 0){
        this.currentPage = this.totalPages - 1;
        this.previousPage = 0;
      }
      else{
        this.previousPage = this.currentPage;
        this.currentPage = page;
      }
      
      console.debug("page " + this.currentPage);
      
      var self = this;
      var direction = (type == 'next' ? 'left' : 'right');
      var next = this.pages[this.currentPage];
      var prev = this.pages[this.previousPage];
      
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

      this.setPageDisplay();
      
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