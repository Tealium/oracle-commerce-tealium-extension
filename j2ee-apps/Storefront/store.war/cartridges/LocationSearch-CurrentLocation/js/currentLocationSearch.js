/**
 * This file contains Javascript utility function used by 
 * LocationSearch-CurrentLocation.jsp to get user location and perform submit
 */

function getLocation(pGeoProperty,pDefaultSearchRadius) {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      dojo.byId('searchNearMe-Nfg').value= pGeoProperty+'|'+position.coords.latitude+'|'+position.coords.longitude+'|'+pDefaultSearchRadius;
      dojo.byId('searchNearMe-Ns').value= pGeoProperty+'('+position.coords.latitude+','+position.coords.longitude+')|0';
      dojo.byId('storeSearchNearMeForm').submit();
    },function(error) {
        if(error.PERMISSION_DENIED) {
		  dojo.byId('GeoNotSupported').style.display='none';
          dojo.byId('GeoRequestDenied').style.display='inline';
        }
    });
  }
  else {
    dojo.byId('GeoRequestDenied').style.display='none';
    dojo.byId('GeoNotSupported').style.display='inline';
  }
}