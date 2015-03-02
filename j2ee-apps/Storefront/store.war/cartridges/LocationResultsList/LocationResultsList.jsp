<%--
  This page is the Store Results List page.
  Displays store list for searched location.

  Required Parameters:
    contentItem
      The content item - results list type 
    
  Optional Parameters:
    None

--%>
<dsp:page>

  <dsp:importbean bean="/atg/store/droplet/StoreDistanceDroplet"/>
  <dsp:importbean bean="/atg/store/droplet/StoreUnitsOfMeasureConversionDroplet"/>
  <dsp:importbean bean="/atg/endeca/store/droplet/ActionURLDroplet"/>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:importbean bean="/atg/multisite/SiteContext"/>
  
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/> 
  <dsp:setvalue param="countryCode" beanvalue="SiteContext.site.defaultCountry"/>
  
  
  <%-- Render the search results. --%>
      
  <dsp:getvalueof var="size" value="${contentItem.totalNumRecs}"/>
  <dsp:getvalueof var="page" value="${contentItem.recsPerPage}"/>
 
 	<h1>H1</h1>
 
  <dsp:importbean bean="/atg/multisite/Site" var="currentSite" />
  <dsp:getvalueof var="siteLocale" value="${currentSite.defaultLanguage}_${currentSite.defaultCountry}" />
  <%-- Render the Tealium tags --%>
  <dsp:droplet name="/tealium/droplet/SiteCoreSearchResultsDroplet">
		<dsp:param name="pageName" value="atg_store_SearchResults" />
		<dsp:param name="language" value="${siteLocale}" />
		<dsp:param name="currency" value="USD" />
		<dsp:param name="searchKeyWord" param="Ntt"/>
		<dsp:param name="totalResultsNumber" value="${size}"/>
   </dsp:droplet> 
 
  <%-- Display the number of search results if this is a query search --%>
  
  <div id="atg_store_mainHeader">
    <div class="atg_store_searchResultsCount">
      <c:choose>  
        <c:when test="${size == 1}">
          <fmt:message var="resultsMessage" key="facet.facetGlossaryContainer.storeFound"/>
        </c:when>
        <c:otherwise>
          <fmt:message var="resultsMessage" key="facet.facetGlossaryContainer.storesFound"/>
        </c:otherwise>
      </c:choose> 
      <span id="resultsCount"><c:out value="${size}"/></span>&nbsp;<c:out value="${resultsMessage}"/>  
    </div>
  </div>
  
  
  <c:choose>
    <%-- No Results --%>
  
    <c:when test="${empty size || size == 0 }">
      <crs:messageContainer optionalClass="atg_store_noMatchingItem crs_store_noMatchingResultsFound" titleKey="store.location.noMatchingResultsFound"/>               
    </c:when>
  
    <%-- Display Results --%>
    
    <c:otherwise>  
              
    <%-- Display sort options --%>
    
      <div class="atg_store_filter">          
        <dsp:form id="sortByForm" action="/crs/store">
          <label for="sortBySelect">
            <fmt:message key="common.sortBy" />:
          </label>            
          <select  id="sortBySelect" name="sort" onchange="location = this.options[this.selectedIndex].value">
            <c:forEach var="sortOption" items="${contentItem.sortOptions}">
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
                <dsp:param name="action" value="${sortOption}"/>                      
                <dsp:oparam name="output">
                  <dsp:getvalueof var="actionURL" param="actionURL"/>
                  <c:set var="sortAction" value="${actionURL}"/>
                </dsp:oparam>
              </dsp:droplet>                
              <option
                <c:if test="${sortOption.selected}">
                selected="true"
                </c:if>
                value="${sortAction}"><fmt:message key="${sortOption.label}"/>
              </option>
            </c:forEach>
          </select>                
          <noscript>
            <span class="atg_store_sortButton">
              <input value="Sort" type="submit"/>
            </span>
          </noscript>
        </dsp:form>          
      </div>
  
     <%--Display top pagination options --%>
  
    <dsp:include page="storeListRangePagination.jsp">
      <dsp:param name="top" value="true" />
      <dsp:param name="contentItem" value="${content}"/>
    </dsp:include>
    
    <%-- Get the default experience manager record detail path for stores. --%>
  
    <dsp:getvalueof var="storePage" bean="/atg/endeca/assembler/cartridge/manager/LocationActionPathProvider.defaultExperienceManagerRecordActionPath"/>
    
    <%-- Store Details Display --%>
    
    <div class="atg_store_locator crs_locator_item">
      <div class="hr"></div>
      <dsp:getvalueof var="counter" param="No"/>
      <c:forEach var="record" items="${contentItem.records}" varStatus="loopStatus">                  
        <dsp:getvalueof var="index" value="${loopStatus.index}"/>
        <dsp:getvalueof var="count" value="${loopStatus.count}"/>
        <dsp:getvalueof var="counter1" value="${counter+count}"/>        
        <dsp:getvalueof var="searchAttribute" value="${record.attributes}"/>
        <%--
          This Droplet is used to extract the distance of store from current location.
               
          Input parameters:
            variable
              Endeca generated recordAttribute used for extracting distance.
            value
              Numeric value to be formatted upto maximum fraction digits.
            fraction
              Maximum fraction digits.
                    
          Output parameter:    
            distance 
              Distance of a store from current location.
          Open parameters: 
            output
              Rendered when recordAttribute has no distance variable.
        --%>   
        <dsp:droplet name="StoreDistanceDroplet">
          <dsp:param name="variable" value="${searchAttribute}"/> 
          <dsp:param name="fraction" value="2"/>
          <dsp:oparam name="output">
            <dsp:getvalueof var="distance" param="distance"/>
          </dsp:oparam>
        </dsp:droplet>
        
        <%-- Store Details in Tabular Form --%> 
        
        <div class="atg_store_contentContainer hr">
          <table class="crs_location_store_width">
            <br>
            <tr>
             
            <%-- First Cell of Table --%>
             
            <c:if test="${not empty distance}">
               
            <%--
              Droplet used to convert a value from one unit of measurement to another
                This droplet takes the following parameters:
                       
              Input parameters:
                value
                  The value (quantity) that will be converted
                from (optional)
                  The starting unit of measure. Null will use locale's default.
                    default will use the base unit of measured defined by the unit of measure tools
                to (optional)
                  The ending unit of measure. Null will use locale's default.
                    default will use the base unit of measured defined by the unit of measure tools
                language (optional)
                  The language of the locale to use
                country (optional)
                  The country of the locale to use
                       
                Output parameters:
                  This droplet renders the following parameters as part of the output:
                  result
                    The resulting quantity after the conversion (in the uom defined by the to parameter)
                  from
                    The initial unit of measure that was used
                  to
                    The resulting unit of measure
                  conversionRate
                    The rate of conversion to convert the unit from the initial uom to the resulting uom
            --%>
               
              <dsp:droplet name="StoreUnitsOfMeasureConversionDroplet">
                <dsp:param name="value" value="${distance}"/> 
                <dsp:param name="from" value="km"/>
                <dsp:oparam name="output">
                  <dsp:getvalueof var="result" param="result"/>
                  <dsp:getvalueof var="to" param="to"/>
                  <dsp:droplet name="StoreDistanceDroplet">
                    <dsp:param name="value" value="${result}"/> 
                    <dsp:param name="fraction" value="2"/>
                    <dsp:oparam name="output">
                      <dsp:getvalueof var="result" param="distance"/>
                    </dsp:oparam>
                  </dsp:droplet>
                  <td class="crs_location_count_width">
                    <div class="crs_store_diamond_image">
                      <div class="crs_padding_counter"><c:out value="${counter1}"/></div>
                    </div>
                    <div><c:out value="${result}"/> <c:out value="${to}"/></div>
                    <div><fmt:message key="store.details.fromYourLocation"/></div>
                  </td>
                </dsp:oparam>
              </dsp:droplet>
            </c:if>
            <c:if test="${empty distance}">
              <td class="crs_location_count_width">
                <div class="crs_store_diamond_image"> 
                  <div class="crs_padding_counter"><c:out value="${counter1}"/></div>
                </div>
              </td>
            </c:if>
               
            <%-- Second Cell of table --%>
               
            <td class="crs_location_hour_width"> 
              <div class="crs_store_bold_text"><c:out value="${record.attributes['store.name']}"/></div>
              <dsp:getvalueof var="Address1" value="${record.attributes['address1']}"/>
              <c:if test="${not empty Address1}">
                <div class="street-address"><c:out value="${Address1}"/></div>
              </c:if>
              <dsp:getvalueof var="Address2" value="${record.attributes['address2']}"/>
              <c:if test="${not empty Address2}">
                <div class="street-address"><c:out value="${Address2}"/></div>
              </c:if>
              <dsp:getvalueof var="Address3" value="${record.attributes['address3']}"/>
              <c:if test="${not empty Address3}">
                <div class="street-address"><c:out value="${Address3}"/></div>
              </c:if>
              <dsp:getvalueof var="City" value="${record.attributes['city']}"/>
              <c:if test="${not empty City}">
                <span class="locality"><c:out value="${City}"/></span>,
              </c:if>
              <dsp:getvalueof var="County" value="${record.attributes['county']}"/>
              <c:if test="${not empty County}">
                <span class="county-name"><c:out value="${County}"/></span>,
              </c:if>
              <dsp:getvalueof var="StateAddress" value="${record.attributes['stateAddress']}"/>
              <c:if test="${not empty StateAddress}">
                <span class="region"><c:out value="${StateAddress}"/></span>,
              </c:if>
              <dsp:getvalueof var="PostalCode" value="${record.attributes['postalCode']}"/>
              <c:if test="${not empty PostalCode}">
                <span class="postal-code"><c:out value="${PostalCode}"/></span>
              </c:if>
              <dsp:getvalueof var="Country" value="${record.attributes['country']}"/>
              <c:if test="${not empty Country}">
                <span class="country-name"><c:out value="${Country}"/></span>
              </c:if>
              <dsp:getvalueof var="PhoneNumber" value="${record.attributes['phoneNumber']}"/>
              <c:if test="${not empty PhoneNumber}">
                <div class="tel">
                  <span class="type"><fmt:message key="common.phone"/></span><fmt:message key="common.labelSeparator"/>
                  <span class="value"><c:out value="${PhoneNumber}"/></span>
                </div>
              </c:if>
              <dsp:getvalueof var="FaxNumber" value="${record.attributes['faxNumber']}"/>
              <c:if test='${not empty FaxNumber}'>
                <div class="tel">
                  <span class="type"><fmt:message key="common.fax"/></span><fmt:message key="common.labelSeparator"/>
                  <span class="value"><c:out value="${FaxNumber}"/></span>
                </div>
              </c:if>
              <dsp:getvalueof var="Email" value="${record.attributes['email']}"/>
              <c:if test="${not empty Email}">
                <a class="email" href="mailto:${email}">
                  <c:out value="${Email}"/>
                </a>
              </c:if>
            </td>
               
            <%-- Third Cell of table --%>
               
            <td class="crs_location_hour_width">
              <dsp:getvalueof var="Hours" value="${record.attributes['hours']}"/>
              <c:if test="${not empty Hours}">
                <div class="crs_store_bold_text"><fmt:message key="store.locationResultList.storeHours"/></div>
                <div><c:out value="${record.attributes['hours']}"/></div>
              </c:if>
            </td>
              
            <%-- Fourth Cell of Table --%>
              
            <td class="crs_location_count_width">
             
              <dsp:a href="${originatingRequest.contextPath}${storePage}${record.detailsAction.recordState}" title="${storeName}">
                <fmt:message key="store.locationResultList.details"/>
                <dsp:param name="storeSize" value="${size}"/>
                <dsp:param name="storeDistance" value="${result}"/>
                <dsp:param name="storeIndex" value="${counter1}"/>
                <dsp:param name="distanceUnit" value="${to}"/>
              </dsp:a>
             
            </td> 
          </tr>  
        </table>
        <br>
      </div>
    </c:forEach>
  </div>
    
  <%--Display bottom pagination options --%>
  
  <dsp:include page="storeListRangePagination.jsp">
    <dsp:param name="top" value="false" />
    <dsp:param name="component" value="${content}"/>
  </dsp:include>
  </c:otherwise>
  </c:choose>
  
  <div name="transparentLayer" id="transparentLayer"></div>
    
  <div name="ajaxSpinner" id="ajaxSpinner"></div>

</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/LocationResultsList/LocationResultsList.jsp#1 $$--%>
