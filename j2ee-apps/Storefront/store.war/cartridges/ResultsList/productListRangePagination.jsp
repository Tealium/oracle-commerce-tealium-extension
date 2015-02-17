<%--  
  Renders page numbers and view all link

  Required Parameters:
    arraySplitSize
      Number of items to be displayed per page.
    start
      Start index of the item to be rendered on this page.
    size
      Total number of items to be displayed
    p
      Current page number.

  Optional Parameters:
    top
      Where to render the pagination links on the page. Set to true for top set of links,
      false for the bottom set.
    viewAll
      Set to true if 'view all' has been requested.
    sort
      How the results should be sorted sorted.
    facetTrail  
      Records the currently supplied faceting on the search results.
    addFacet
      Facet to be added to the facet trail
    categoryId
      The currently browsed category
--%>
<dsp:page>

  <dsp:importbean bean="/atg/endeca/store/droplet/ActionURLDroplet"/>
  <dsp:importbean bean="/atg/store/droplet/ArraySubsetHelper"/>
  
  <dsp:getvalueof var="viewAll" param="viewAll"/>
  <dsp:getvalueof var="top" param="top"/>
  <dsp:getvalueof var="contentItem" 
                  vartype="com.endeca.infront.assembler.ContentItem" 
                  param="contentItem"/>

  <c:set var="size" value="${contentItem.totalNumRecs}" />
  <c:set var="arraySplitSize" value="${contentItem.recsPerPage}"/>
  <c:set var="start" value="${contentItem.firstRecNum}"/>
  
  <c:set var="viewAllLinkClass" value="atg_store_actionViewAll"/>
  
  <c:if test="${size > arraySplitSize}">

    <crs:pagination size="${size}" arraySplitSize="${arraySplitSize}" 
                    start="${start}" viewAll="${viewAll}" top="${top}">
  
      <jsp:attribute name="pageLinkRenderer"> 
        <%-- RENDER PAGE LINKS --%>  
        
        <%--
          This droplet builds a complete URL string for the Endeca 
          generated action object. The action can be represented 
          either by NavigationAction, RecordAction or UrlAction.
           
          Input parameters:
            action
              An action object to produce URL for.
     
          Output parameters:    
            actionURL
              A URL for the passed in action Object.
       
          Open parameters: 
            output
              Rendered when the non-empty URL is represented 
              by the Action object.   
        --%>
        <dsp:droplet name="ActionURLDroplet">
          <dsp:param name="action" value="${contentItem.pagingActionTemplate}"/>
          
          <dsp:oparam name="output">
            <dsp:getvalueof var="actionURL" param="actionURL"/>
            <c:set var="url" value="${actionURL}"/>
            <c:set var="pageTemplate" value="${url}"/>
          </dsp:oparam>
        </dsp:droplet>
        
        <c:set var="linkAction" value="${fn:replace(
          fn:replace(pageTemplate, '%7Boffset%7D', startValue - 1), 
                     '%7BrecordsPerPage%7D', arraySplitSize)}" />
        
        <c:set var="url" value="${linkAction}"/>

        <c:choose>
          <c:when test="${selected && !viewAll}">
            <a title="${linkTitle}" class="${linkClass}">${linkText}</a>
          </c:when>
          <c:otherwise>
            <a href="${url}" title="${linkTitle}" 
               class="${linkClass}">${linkText}</a>
          </c:otherwise>
        </c:choose>
      </jsp:attribute>

    </crs:pagination>
  </c:if>
</dsp:page>

<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/ResultsList/productListRangePagination.jsp#1 $$Change: 848678 $ --%>