/**
 * This file contains Javascript functions used by LocationSearchRadius renderer alone.
 */

dojo.ready(function(){
  if (!navigator.geolocation){
    //hide the radius refinement filter all together.
    dojo.query('.atg_store_geoFilter_refinement').style("display", "none");
  }
});

function filterByNewRadius(pNewRadius, pGeoProperty){
  // Access user's current position
  navigator.geolocation.getCurrentPosition(function(pPosition){
    //Create url to refine result by current position and search radius
    var uri = decodeURIComponent(window.location.href.replace(/\+/g,  " "));
    var query;
    if (uri.indexOf("?")==-1){
      // url DOES NOT contain any querystring parameters
      // simply add new geo filter querystring parameter
      query = {
        Nfg: pGeoProperty + "|" + 
            pPosition.coords.latitude + "|" + 
            pPosition.coords.longitude + "|" + 
            pNewRadius,
        Ns: pGeoProperty + "(" + 
            pPosition.coords.latitude + "," + 
            pPosition.coords.longitude + ")|0"
      };
    } 
    else {
      // keep existing querystring parameters AND
      // add (or replace) geo filter querystring
      query = dojo.queryToObject(uri.substring(uri.indexOf("?") + 1, uri.length));
      query.Nfg = pGeoProperty + "|" + 
          pPosition.coords.latitude + "|" + 
          pPosition.coords.longitude + "|" + 
          pNewRadius;
      query.Ns = pGeoProperty + "(" + 
          pPosition.coords.latitude + "," + 
          pPosition.coords.longitude + ")|0";
      
      // remove existing querystring values from the url string
      uri = uri.substring(0, uri.indexOf("?"));
    }

    // append querystring parameters to the url
    uri += "?" + dojo.objectToQuery(query);

    // reload the page
    window.location.href = uri;
  });
    
}
  