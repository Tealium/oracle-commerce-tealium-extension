<%--
  ~ Copyright 2001, 2012, Oracle and/or its affiliates. All rights reserved.
  ~ Oracle and Java are registered trademarks of Oracle and/or its
  ~ affiliates. Other names may be trademarks of their respective owners.
  ~ UNIX is a registered trademark of The Open Group.

  Renders the ScrollablePromotionalContent carousel used to scroll through the 
  promotional content items.
    
  Required Parameters:
    contentItem
      The content item to render.
--%>
<dsp:page>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/> 
  <dsp:getvalueof var="totalNumItems" value="${fn:length(contentItem['atg:contents'].items)}"/>
  <dsp:getvalueof var="contextPath" vartype="java.lang.String" value="${originatingRequest.contextPath}"/>
  <fmt:message var="previous" key="common.previous"/>
  <fmt:message var="next" key="common.next"/>

  <%--
      In order to support multiple widgets of the same type on the same page
      each widget instance needs a unique id. spcwInstanceNo will be incremented
      for each widget and is appended to widget id to ensure it is unique
  --%>
  <c:choose>
    <c:when test='${empty spcwInstanceNo}'>
      <c:set var="spcwInstanceNo" value="0" scope="request"/>
    </c:when>
    <c:otherwise>
      <c:set var="spcwInstanceNo" value="${spcwInstanceNo + 1}" scope="request"/>
    </c:otherwise>
  </c:choose>
  
  <c:set var="renderControls" value="${totalNumItems > 1 }"/>
  
  <%--
    Instantiate the Dojo ScrollablePromotionalContent widget, passing in values
    for any properties that are required or that require a value other than
    the default value. See ScrollablePromotionalContent.js
  --%>
  <span dojotype="atg.store.widget.ScrollablePromotionalContent"
        id="promo_carousel${spcwInstanceNo}"
        siteContextPath="${contextPath}"
        previousLinkTitle="${previous}"
        nextLinkTitle="${next}"
        totalItems="${totalNumItems}"
        style="display: none">
    
    <c:if test="${renderControls eq true}">    
      <div class="prev_button">
        <span class="navlink">
          <a href="#" title="${previous}">${previous}</a>
        </span>
      </div>
    </c:if>
    
    <%-- Render the list of promotional content items --%>    
    <div class="carousel_inner">
      <c:forEach var="promotionalContent" items="${contentItem['atg:contents'].items}" varStatus="status">
        <dsp:getvalueof var="imageUrl" vartype="java.lang.String" value="${promotionalContent.derivedImage}"/>
        <dsp:getvalueof var="linkUrl" vartype="java.lang.String" value="${promotionalContent.linkUrl}"/>
        
        <%--
          When the linkUrl, which is an explicit url, isnt defined try linking
          to the associatedCategory
        --%>
        <c:if test="${empty linkUrl}">

          <dsp:getvalueof var="associatedCategory" vartype="java.lang.String" value="${promotionalContent.associatedCategory}"/>

          <c:if test="${not empty associatedCategory}">

            <%--
              Look in a cache of ATG repository Id to Endeca navigationStates for the 
              URL that will be used to navigate to when an Endeca driven category page
              is clicked.
            
              Input Parameters:
                repositoryId - The repository id of the value we want to retrieve from
                                 the cache.
                
              Open Parameters:
                output - Serviced when no errors occur.
       
              Output Parameters:
                dimensionValueCacheEntry - The entry in the cache for this particular
                                           repository id and ancestors. 
            --%>
            <dsp:droplet name="/atg/commerce/endeca/cache/DimensionValueCacheDroplet">
              <dsp:param name="repositoryId" value="${associatedCategory.repositoryId}"/>
              <dsp:oparam name="output">
                <dsp:getvalueof var="associatedCategoryDimVal" param="dimensionValueCacheEntry" />
              </dsp:oparam>
            </dsp:droplet>
            
            <c:choose>
              <c:when test="${not empty associatedCategoryDimVal}">
                <c:set var="linkUrl" value="${associatedCategoryDimVal.url}"/>
              </c:when>
              <c:otherwise>
                <%-- 
                  Should we render categories we cant navigate to? Default is only in a 
                  preview environment. 
                --%>  
                <dsp:getvalueof var="showUnindexedCategories" bean="/atg/store/StoreConfiguration.showUnindexedCategories"/>
                <c:if test="${showUnindexedCategories eq true}">
                  <dsp:getvalueof var="actionPath" 
                bean="/atg/endeca/assembler/cartridge/manager/DefaultActionPathProvider.defaultExperienceManagerNavigationActionPath"/>
                  <c:set var="linkUrl" value="${actionPath}?categoryId=${associatedCategory.repositoryId}"/>

                </c:if>
              </c:otherwise>
            </c:choose>
          </c:if>
        </c:if>
        
        <div class="item ${status.count==1 ? 'active' : ''}">
          <%-- Display promotion image. --%>
          <a href="${contextPath}${linkUrl}" title="${promotionalContent.storeDisplayName}">
            <span class="atg_store_promotionItem">
              <c:choose>
                <c:when test="${empty imageUrl}">
                  <fmt:message key="common.image"/>
                </c:when>
                <c:otherwise>
                  <dsp:img src="${imageUrl}"/>
                </c:otherwise>
              </c:choose>
            </span>
          </a>
        </div>
        
      </c:forEach>
    </div>
    
    <%-- Display the promotional content image indicator --%>
    <c:if test="${renderControls eq true}">
      <div class="indicator_wrapper">
        <ol id="carousel_indicator" class="indicator">
          <c:forEach var="promotionalContent" items="${contentItem['atg:contents'].items}" varStatus="status">
            <li data-indicator="${status.count - 1}"></li>
          </c:forEach>
        </ol>
      </div>
      
      <div class="next_button">
        <span class="navlink">
          <a href="#" title="${next}">${next}</a>
        </span>
      </div>
    </c:if>

  </span>

</dsp:page>