<%-- 

  ~ Copyright 2001, 2012, Oracle and/or its affiliates. All rights reserved.
  ~ Oracle and Java are registered trademarks of Oracle and/or its
  ~ affiliates. Other names may be trademarks of their respective owners.
  ~ UNIX is a registered trademark of The Open Group.
  
  
  This page lays out the elements that make up the Store Search by State 
  Content.
    
  Required Parameters:
    None.
   
  Optional Parameters:
    None.
--%>

<dsp:page>
  <div class="pageFormatStateSearch">
    <dsp:importbean bean="/OriginatingRequest" var="originatingRequest" />
    <dsp:importbean bean="/atg/store/droplet/StoreLookupDroplet" />
    <dsp:importbean bean="/atg/store/droplet/StoreSiteFilterDroplet" />
    <dsp:importbean bean="/atg/store/droplet/StateListFilterDroplet" />
    <dsp:importbean bean="/atg/multisite/SiteContext" />
    <dsp:getvalueof var="contextPath" vartype="java.lang.String"
      value="${originatingRequest.contextPath}" />
    <dsp:getvalueof var="actionPath"
      bean="/atg/endeca/assembler/cartridge/manager/LocationActionPathProvider.defaultExperienceManagerNavigationActionPath" />
    <dsp:setvalue param="country"
      beanvalue="SiteContext.site.defaultCountry" />
    <dsp:form action="${contextPath}${actionPath}" id="stateSearchForm"
      requiresSessionConfirmation="false">
      <input type="hidden" name="Ns" id="Ns" value="store.city|0" />
      <input type="hidden" name="Ntt" id="Ntt" />
      <div class="textFormatAlignCenter">
        <div class="textFormatSearchALocation">
          <p>
            <fmt:message key="store.location.searchALocation" />
          </p>
        </div>
        <select id="stateName" name="search" onchange="submitSearchForm()">
          <option value="">
            <fmt:message key="common.selectState" />
          </option>
          <%-- Lookup stores from repository --%>
          <%--
          This droplet returns collection of all store repository items.
            Input parameters:
              none
            Output parameter:    
              collection 
                A collection of store RepositoryItems.
            Open parameters: 
              output
                Rendered when stores are found in repository
              empty
                Rendered when no stores are found in repository
          --%>
          <dsp:droplet name="StoreLookupDroplet">
            <dsp:oparam name="output">
              <%-- Filter stores for current site --%>
              <%--
              This droplet filters the collection of all store repository items 
              for the current site and returns the filtered collection.
              Input parameter:
                collection
                  A collection of store RepositoryItems.
              Output parameter: 
                A collection of store RepositoryItems for particular site.
              Open parameter: 
                output
                  Rendered when stores for current site are found in repository
              --%>
              <dsp:droplet name="StoreSiteFilterDroplet">
                <dsp:param name="collection" param="items" />
                <dsp:oparam name="output">
                  <%-- Iterate collection of stores --%>
                  <%--
                  This droplet returns the list of states for a given 
                  country code. 
                  Input parameters:
                    countryCode
                      The country code for the current site.
                    statesCode
                      A collection of filtered store RepositoryItems      
                  Output parameter:    
                    A list of states having stores.
                  Open parameter:
                    output
                      Rendered when states, having stores, are found
                  --%>
                  <dsp:droplet name="StateListFilterDroplet">
                    <dsp:param name="countryCode" param="country" />
                    <dsp:param name="stateCodes" param="filteredCollection" />
                    <dsp:oparam name="output">
                      <dsp:getvalueof var="states" param="states" />
                      <%-- Check if selected country have states --%>
                      <c:set var="numOfStates" value="${fn:length(states)}" />
                      <c:if test="${numOfStates > 0}">
                        <c:forEach var="state" items="${states}">
                          <dsp:param name="state" value="${state}" />
                          <dsp:getvalueof var="code" vartype="java.lang.String"
                            param="state.code">
                            <option value="${code}">
                              <dsp:valueof param="state.displayName" />
                            </option>
                          </dsp:getvalueof>
                        </c:forEach>
                      </c:if>
                    </dsp:oparam>
                  </dsp:droplet>
                </dsp:oparam>
              </dsp:droplet>
            </dsp:oparam>
            <dsp:oparam name="empty">
              <fmt:message key="company_stores.noStoresFound" />
            </dsp:oparam>
          </dsp:droplet>
        </select>
      </div>
    </dsp:form>
  </div>
</dsp:page>
<script type="text/javascript"
  src="${pageContext.request.contextPath}/cartridges/LocationSearch-StateSearch/js/stateSearch.js"></script>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/LocationSearch-StateSearch/LocationSearch-StateSearch.jsp#1 $--%>