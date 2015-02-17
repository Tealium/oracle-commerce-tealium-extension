/**
 * This file contains Javascript utility function used by 
 * LocationBreadcrumbs.jsp to clear the geosort in case geocrumb is getting removed.
 */

function clearGeoSort(pUri, pGeoProperty) {
  var uri = decodeURIComponent(pUri.replace(/\+/g,  " "));
  var query = {};
  if (uri.indexOf("?") != -1) {
    // keep existing querystring parameters AND
    // remove geosort if present
    query = dojo.queryToObject(uri.substring(uri.indexOf("?") + 1, uri.length));
    if (query.Ns && query.Ns.indexOf(pGeoProperty) != -1) {
      delete query.Ns;
    }

    // remove existing querystring values from the url string
    uri = uri.substring(0, uri.indexOf("?"));
  }

  // append querystring parameters to the url
  uri += "?" + dojo.objectToQuery(query);

  // reload the page
  window.location.href = uri;
}