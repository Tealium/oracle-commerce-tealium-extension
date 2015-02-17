<%-- 
  ~ Copyright 2001, 2012, Oracle and/or its affiliates. All rights reserved.
  ~ Oracle and Java are registered trademarks of Oracle and/or its
  ~ affiliates. Other names may be trademarks of their respective owners.
  ~ UNIX is a registered trademark of The Open Group.
  
  
  This page lays out the elements that make up the Store Search by Current
  location Content.
    
  Required Parameters:
    None.
   
  Optional Parameters:
    None.
--%>
<dsp:page>
  <div class="pageFormatCurrentLocation">
    <dsp:importbean
      bean="/atg/store/droplet/StoreUnitsOfMeasureConversionDroplet" />
    <dsp:importbean bean="/OriginatingRequest" var="originatingRequest" />
    <dsp:getvalueof var="contextPath" vartype="java.lang.String"
      value="${originatingRequest.contextPath}" />
    <dsp:getvalueof var="actionPath"
      bean="/atg/endeca/assembler/cartridge/manager/LocationActionPathProvider.defaultExperienceManagerNavigationActionPath" />
    <dsp:getvalueof var="contentItem"
      vartype="com.endeca.infront.assembler.ContentItem"
      value="${originatingRequest.contentItem}" />
    <dsp:form action="${contextPath}${actionPath}"
      id="storeSearchNearMeForm" requiresSessionConfirmation="false">
      <input type="hidden" id="searchNearMe-Nfg" name="Nfg" />
      <input type="hidden" id="searchNearMe-Ns" name="Ns" />
      <div class="textFormatAlignCenter">
        <div class="textFormatSearchNearMe">
          <p>
            <fmt:message key="store.location.searchNearMe" />
          </p>
        </div>
        <dsp:droplet name="StoreUnitsOfMeasureConversionDroplet">
          <dsp:param name="value" value="${contentItem.defaultSearchRadius}" />
          <dsp:param name="to" value="km" />
          <dsp:oparam name="output">
            <dsp:getvalueof var="result" param="result" />
          </dsp:oparam>
        </dsp:droplet>
        <span class="atg_store_basicButton"> <input type="button"
          name="search"
          value="<fmt:message key="store.location.findStores"/>"
          onclick="getLocation('${contentItem.geoProperty}','${result}')" />
        </span>
        <div id="GeoNotSupported" style="display: none;">
          <div class="textFormatGeoLocationNotSupported">
            <fmt:message key="store.location.geoLocationNotSupported" />
          </div>
        </div>
		<div id="GeoRequestDenied" style="display: none;">
          <div class="textFormatGeoLocationNotSupported">
            <fmt:message key="store.location.geoLocationRequestDenied" />
          </div>
        </div>
      </div>
    </dsp:form>
  </div>
</dsp:page>
<script type="text/javascript"
  src="${pageContext.request.contextPath}/cartridges/LocationSearch-CurrentLocation/js/currentLocationSearch.js"></script>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/LocationSearch-CurrentLocation/LocationSearch-CurrentLocation.jsp#1 $--%>