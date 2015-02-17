<%--
  Renders Product Spotlight Slots
--%>
<dsp:page>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:importbean bean="/atg/commerce/catalog/ProductLookup"/>
  <dsp:importbean bean="/atg/multisite/Site"/>
  
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/> 
  <dsp:getvalueof var="items" value="${contentItem['atg:contents'].items}"/> 

  <c:if test="${not empty items}">
    <div id="atg_store_prodList">
    
      <div id="atg_store_spotlightText">
        <h3>
          <%-- Display the title for this spotlight. --%>
          <crs:outMessage key="productTargeter_spotlightTitle" />
        </h3>
      </div>

      <ul class="atg_store_product">
      
        <c:set var="count" value="${fn:length(items)}"/>
        <c:if test="${count gt contentItem.itemCount}">
          <c:set var="count" value="${contentItem.itemCount}"/>
        </c:if>
      
        <c:forEach items="${items}" var="productItem" begin="1" end="${count}">  
          <li>

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
                  Generates a URL for the product, the URL is stored in the 
                  productUrl request scoped variable.
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
               
          </li>
        </c:forEach> 
       
      </ul>
                    
    </div>
  </c:if>
  
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/ProductSpotlight-ATGSlot/ProductSpotlight-ATGSlot.jsp#1 $$Change: 848678 $ --%>