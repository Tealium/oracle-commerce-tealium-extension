<%--
  LocationBreadcrumbs
  
  Renders refinements that have been selected. Selected refinements can consist
  of search refinements, dimension refinements or geo-filter refinements.
  
  There are a number of different types of breadcrumb that can be returned
  inside this content item:
    refinementCrumbs - As a result of selecting a dimension
    searchCrumbs - As a result of performing a search
    geoFilterCrumb - As a result of search by geocode
--%>
<dsp:page>

  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:importbean bean="/atg/store/droplet/StoreUnitsOfMeasureConversionDroplet"/>
  <dsp:getvalueof var="content" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/> 
  <dsp:getvalueof var="contextPath" vartype="java.lang.String" value="${originatingRequest.contextPath}"/>

  <c:if test="${not empty content.refinementCrumbs || not empty content.searchCrumbs || not empty content.geoFilterCrumb}">  
    <div id="atg_store_dimensionRefinements" class="atg_store_dimensionRefinementsSelected">

      <%-- Show "Your Selections" label--%>
      <h5><fmt:message key="common.yourSelectionsLabel"/></h5>
      
      <%-- Display searched terms if there are any --%>
      <c:if test="${not empty content.searchCrumbs}">
        <fmt:message var="searchTextQuotes" key="common.breadcrumbs.searchTextQuote"/>
        <div class="atg_store_refinements">
          <c:forEach var="searchCrumb" items="${content.searchCrumbs}"> 
          
            <%-- If search term was corrected, display corrected version --%>  
            <dsp:getvalueof var="searchTerm" value="${searchCrumb.correctedTerms}"/>  
            <c:if test="${empty searchTerm}">
              <dsp:getvalueof var="searchTerm" value="${searchCrumb.terms}"/>
            </c:if>
            
            <%-- Display crumb link --%>   
            <dsp:include page="/global/renderNavLink.jsp">
              <dsp:param name="navAction" value="${searchCrumb.removeAction}"/>
              <dsp:param name="text" value="${searchTextQuotes}${searchTerm}${searchTextQuotes}"/>
              <dsp:param name="showRemoveLink" value="true"/>
            </dsp:include>
          </c:forEach>
        </div>
      </c:if>      

      <%-- Display all selected refinements if there are any.  e.g "CA" --%>
      <c:forEach var="dimCrumb" items="${content.refinementCrumbs}">
        <div class="atg_store_refinements">    
           <c:if test="${empty dimCrumb.ancestors}">
             <dsp:include page="/global/renderNavLink.jsp">
               <dsp:param name="navAction" value="${dimCrumb.removeAction}"/>
               <dsp:param name="text" value="${dimCrumb.label}"/>
               <dsp:param name="showRemoveLink" value="true"/>
             </dsp:include>    
          </c:if>
        </div>
      </c:forEach>
      
      <%-- Display geofilter crumb if there are any.  e.g "Within 5 Miles" --%>
      <c:if test="${not empty content.geoFilterCrumb}">
        <div class="atg_store_refinements">
          <dsp:getvalueof var="geoCrumb" value="${content.geoFilterCrumb}"/>
          
          <%-- 
            Convert search radius from kilometer to locale based unit that is in use.
           
            Input parameters:
            value
              search radius in km
            from
              km
            Output parameters:
              to
                Unit as per shopper's locale
              result
                search radius in unit as per shopper's locale
          --%> 
          <dsp:droplet name="StoreUnitsOfMeasureConversionDroplet">
            <dsp:param name="value" value="${geoCrumb.radiusKM}"/> 
            <dsp:param name="from" value="km"/>
            <dsp:oparam name="output">
              <dsp:getvalueof var="result" param="result"/>
              <dsp:getvalueof var="to" param="to"/>
              <fmt:formatNumber var="radius" value="${result}" groupingUsed="false" maxFractionDigits="0" />
              <c:set var="radiusAndUnit" value="${radius} ${to}"/>
            </dsp:oparam>
          </dsp:droplet>         
 
          <%-- Create message crumb to be displayed --%>
          <fmt:message var="resultsMessage" key="store.breadcrumbs.searchNearMe">
            <fmt:param>
              <c:out value="${radiusAndUnit}"/>
            </fmt:param>
          </fmt:message>

          <%-- Display crumb link --%> 
          <dsp:a href="javascript:clearGeoSort('${contextPath}${geoCrumb.removeAction.contentPath}${geoCrumb.removeAction.navigationState}', '${geoCrumb.propertyName}');" 
            class="${ showRemoveLink == true ? 'atg_store_actionDelete' : ''}"><c:out value="${resultsMessage}"/></dsp:a>  
        </div>
      </c:if>

    </div>  
  </c:if>
</dsp:page>
<script type="text/javascript"
  src="${pageContext.request.contextPath}/cartridges/LocationBreadcrumbs/js/locationBreadcrumbs.js"></script>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/LocationBreadcrumbs/LocationBreadcrumbs.jsp#1 $$Change: 848678 $--%>
