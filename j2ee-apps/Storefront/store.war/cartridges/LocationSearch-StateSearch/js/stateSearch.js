/**
 * This file contains Javascript utility function used by 
 * LocationSearch-StateSearch.jsp to perform submit on state selection
 */

function submitSearchForm()
{
  var state = dojo.byId('stateName').value;
  if (state != "")
  {
    dojo.byId('Ntt').value = state;
    dojo.byId('stateSearchForm').submit();
  }
}