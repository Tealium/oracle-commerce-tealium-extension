<%--
  Renders StoreSpecificDetail cartridge content.

  Required parameters:
    None.
    
  Optional parameters:
    None.
--%>
<dsp:page>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" 
                  value="${originatingRequest.contentItem.record}"/>
  <dsp:getvalueof var="storeImagePath" vartype="com.endeca.infront.assembler.ContentItem" 
                  value="${originatingRequest.contentItem.storeImagePath}"/>
  <dsp:importbean bean="/atg/endeca/store/droplet/ActionURLDroplet"/>
  
  <div class="atg_store_main">
    <dsp:getvalueof var="storeSize" param="storeSize"/>
    <dsp:getvalueof var="storeIndex" param="storeIndex"/>
    <dsp:getvalueof var="storeDistance" param="storeDistance"/>
    <dsp:getvalueof var="distanceUnit" param="distanceUnit"/>
    <div class="store-search-summary">
      <fmt:message var="detailsHash" key="store.details.hash"/>
      <c:out value="${detailsHash}"/>
      <c:out value="${storeIndex}"/>
      <fmt:message var="detailsOf" key="store.details.of"/>
      <c:out value="${detailsOf}"/>
      <c:out value="${storeSize}"/>
      <c:choose>
        <c:when test="${storeSize == '1'}">
          <fmt:message var="storeFound" key="facet.facetGlossaryContainer.storeFound"/>
        </c:when>
        <c:otherwise>
          <fmt:message var="storeFound" key="facet.facetGlossaryContainer.storesFound"/>
        </c:otherwise>
      </c:choose>
      <c:out value="${storeFound}"/>
    </div>

    <c:set var="storeItem" value="${contentItem.attributes}"/>

    <div class="store-details-addr">
      <h1> 
        <div class="crs_store_bold_text"> 
          <c:out value="${storeItem.name}"/> 
        </div>
      </h1>
      <div> 
        <fmt:message var="resultsMessage" key="store.details.storeHash"/>
        <c:out value="${resultsMessage}"/> 
        <c:out value="${storeItem.externalLocationId}"/>
      </div>
      
      <div class="address-table"> 
        <div class="address-cell-left">
          <table>
            <tr>
              <td width="40px">
                <img src="/crsdocroot/content/images/phone.jpg">
              </td>
              <td>
                <div><c:out value="${storeItem.phoneNumber}"/></div>
              </td>
            </tr>
          </table>
        </div> 
      </div>
      
      <div class="address-table"> 
        <div class="address-cell-left"> 
          <table>
            <tr>
              <td width="40px">
                <img src="/crsdocroot/content/images/address.jpg">
              </td>
              <td>
                <div>
                  <c:out value="${storeItem.address1}"/>
                  <c:out value="${storeItem.address2}"/>
                  <c:out value="${storeItem.address3}"/>
                </div>
                <div>
                  <c:out value="${storeItem.city}"/>,
                  <c:out value="${storeItem.county}"/>
                  <c:out value="${storeItem.stateAddress}"/>
                </div>
                <div>
                  <c:out value="${storeItem.postalCode}"/>
                  <c:out value="${storeItem.country}"/>
                </div>
              </td>
            </tr>
          </table>
        </div> 
        <div class="address-cell-right">
          <c:if test="${not empty storeDistance}">
            <div class="crs_store_bold_text">
              <c:out value="${storeDistance}"/>
              <c:out value="${distanceUnit}"/>
            </div>
            <fmt:message var="resultsMessage" 
              key="store.details.fromYourLocation"/>
            <c:out value="${resultsMessage}"/>
          </c:if>
        </div>
      </div>
      
      <div class="address-table">
        <div class="address-cell-left">
          <table>
            <tr>
              <td width="40px">
                <img src="/crsdocroot/content/images/hours.jpg">
              </td>
              <td>
                <div class="crs_store_bold_text">
                  <fmt:message key="store.locationResultList.storeHours"/>
                </div>
                <div>
                  <c:out value="${storeItem.hours}"/>
                </div>
              </td>
            </tr>
          </table>
        </div>
      </div>
      
      <div class="address-table">
        <div class="address-cell-left">
          <table>
            <tr>
              <td width="40px">
                <img src="/crsdocroot/content/images/fax.jpg">
              </td>
              <td>
                <dsp:getvalueof var="FaxNumber" value="${storeItem.faxNumber}"/>
                <c:if test='${not empty FaxNumber && FaxNumber != ""}'>
                  <div>
                    <span class="type"><fmt:message key="common.fax"/></span><fmt:message key="common.labelSeparator"/>
                    <span class="value"><c:out value="${FaxNumber}"/></span>
                  </div>
                </c:if>
                <dsp:getvalueof var="Email" value="${storeItem.email}"/>
                <c:if test="${not empty Email}">
                  <div>
                  <a class="email" href="mailto:${Email}">
                    <c:out value="${Email}"/>
                  </a>
                  </div>
                </c:if>
              </td>
            </tr>
          </table>
        </div>
      </div> 
  
      <div class="address-table"> 
        <div class="address-cell-left"> 
          <a href="javascript: window.history.back();">  
            <fmt:message var="resultsMessage" 
                         key="store.details.backToResults"/>
            <c:out value="<<" />
            <c:out value="${resultsMessage}"/> 
          </a> 
        </div>
      </div>
    </div>
     
    <div class="store-details-image">
      <img src="${storeImagePath}">
    </div>
  </div>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/dev/artemis_idc/Storefront/j2ee/store.war/cartridges/StoreSpecificDetail/StoreSpecificDetail.jsp#1 --%>
