<%--
  Renders a list of products within a Dojo horizontal scroller widget.
  The widget provides paging by means of previous and next buttons
  to move back/forward through sub pages of products. 

  Required parameters:
    contentItem
      The content item to render.
      
  Optional Parameters:
    none
--%>

<dsp:page>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest" />
  <dsp:importbean bean="/atg/commerce/catalog/ProductLookup"/>
  <dsp:importbean bean="/atg/multisite/Site"/>
  
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/>
  <dsp:getvalueof var="itemsPerPage" value="5"  /> <%-- Hardcoded but the XMGR template can be updated to provide this --%>
  <dsp:getvalueof var="contextPath" vartype="java.lang.String" value="${originatingRequest.contextPath}"/>
  <c:set var="totalProducts" value="${fn:length(contentItem['atg:contents'].items)}"/>
  <c:set var="pagingAction" value="${contentItem.pagingActionTemplate.navigationState}" />
  <fmt:message var="previous" key="common.previous"/>
  <fmt:message var="next" key="common.next"/>

  <%--
    In order to support multiple widgets of the same type on the same page
    each widget instance needs a unique id. spswInstanceNo will be incremented
    for each widget and is appended to widget id to ensure it is unique
  --%>
  <c:choose>
    <c:when test='${empty spswInstanceNo}'>
      <c:set var="spswInstanceNo" value="0" scope="request"/>
    </c:when>
    <c:otherwise>
      <c:set var="spswInstanceNo" value="${spswInstanceNo + 1}" scope="request"/>
    </c:otherwise>
  </c:choose>

  <%--
    Instantiate the Dojo widget, passing in values for any properties that are
    required or that require a value other than the default value. See 
    ScrollableProductSpotlight.js
  --%>
  <span dojotype="atg.store.widget.ScrollableProductSpotlight"
        id="scrollableProductSpotlight${spswInstanceNo}"
        pageSize="${itemsPerPage}"
        totalProducts="${totalProducts}"
        previousLinkTitle="${previous}"
        nextLinkTitle="${next}"
        style="display: none">
         
    <div class="carousel_inner">
      <c:forEach var="productItem" items="${contentItem['atg:contents'].items}" varStatus="status">
        <preview:repositoryItem item="${productItem}">
          <div class="product">
          
            <%--
              This droplet searches for a product in the ProductCatalog repository.
  
              Input parameters:
                id - A product's ID to be found.
        
              Output parameters:
                element - The product whose ID matches the 'id' input parameter.
  
              Open parameters:
                output - Rendered when product is found.
            --%>
            <dsp:droplet name="ProductLookup">
              <dsp:param name="id" value="${productItem.repositoryId}"/>
              <dsp:param name="filterBySite" value="false"/>
              <dsp:param name="filterByCatalog" value="false"/>
              <dsp:oparam name="output">
                <%-- 
                  Generates a URL for the product, the URL is stored in the productUrl
                  request scoped variable.
                --%>
                <dsp:include page="/global/gadgets/productLinkGenerator.jsp">
                  <dsp:param name="product" param="element"/>
                </dsp:include>
              </dsp:oparam>
            </dsp:droplet>        
  
            <%-- Render the product details --%>
            <a href="${productUrl}">
                
              <%-- Product Image --%>
              <span class="atg_store_productImage">
                <img src="${httpServer}${productItem.mediumImage.url}" border="0" alt="${productItem.displayName}"/>
              </span>
                
              <%-- Product name --%>
              <span class="atg_store_productTitle">
                <c:out value="${productItem.displayName}"/>
              </span>
                
              <%-- Product price --%>
              <span class="atg_store_productPrice">
                <dsp:include page="/global/gadgets/priceDisplay.jsp">
                  <dsp:param name="highestListPrice" value="${productItem.highestListPrice}"/>
                  <dsp:param name="highestSalePrice" value="${productItem.highestSalePrice}"/>
                  <dsp:param name="lowestListPrice" value="${productItem.lowestListPrice}"/>
                  <dsp:param name="lowestSalePrice" value="${productItem.lowestSalePrice}"/>       
                </dsp:include>
              </span>  
                
              <%-- Site indicator icon --%>
              <dsp:getvalueof var="productSite" value="${productItem.siteId}" />
              <dsp:getvalueof var="siteId" bean="Site.id" />
              <c:if test="${productSite ne siteId}">
                <span class="siteIndicatorBannerContainer">        
                  <span class="siteIndicatorBanner"><c:out value="${productItem.siteName}"/></span>
                </span>
              </c:if>
            </a>          
          </div>
        </preview:repositoryItem>        
      </c:forEach>
    </div>
    
    <c:if test="${totalProducts > itemsPerPage}">
      <div class="navigationWrapper">
        <div class="navigation">
          <span class="control previous"></span>
          <span class="pageNum"></span>
          <span class="control next"></span>
        </div>
      </div>
    </c:if>
    
  </span>
  
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/ScrollableProductSpotlight-ATGSlot/ScrollableProductSpotlight-ATGSlot.jsp#1 $$Change: 848678 $--%>
