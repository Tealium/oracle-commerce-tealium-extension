<%-- 
  On this page we want to show both the standard price range and the sale price 
  range (if one exists). To do so, we call the PriceRangeDroplet twice, once for
  the standard prices and a second time for the sale prices.

  Required Parameters:
    product
      the product repository item to display a range of prices for
  
  Optional Parameters:
    None
--%>
<dsp:page>
  <dsp:importbean bean="/atg/userprofiling/Profile"/>

  <dsp:getvalueof var="product" param="product"/>
  <dsp:getvalueof var="sku" param="sku"/>
  
  <%-- 
    Check the size of the sku array. When theres only 1 sku we render a single
    price, otherwise we render a range.
  --%>
  <c:if test="${empty sku}">
    <dsp:getvalueof var="childSKUs" param="product.childSKUs"/>
    <c:if test="${fn:length(childSKUs) eq 1}">
      <dsp:getvalueof var="sku" value="${product.childSKUs[0]}"/>
    </c:if>
  </c:if>
  
  <c:choose>
    <c:when test="${not empty sku}">
      <%-- SINGLE PRICE --%>
      <dsp:importbean bean="/atg/commerce/pricing/priceLists/PriceDroplet"/>

      <%--
        At first, look up for the list price for the product/SKU specified. This
        droplet searches for a price defined in the price list specified for 
        the product/SKU pair.

        Input parameters:
          product - Search the price for this product.
          
          sku - Search the price for this SKU.
      
          priceList - Search the price in this price list.

        Output parameters:
          price - Price bean with price info found.

        Open parameters:
          output - Rendered if price is found in the price list specified.
          
          empty - Rendered otherwise.
      --%>
      <dsp:droplet name="PriceDroplet">
        <dsp:param name="product" param="product"/>
        <dsp:param name="sku" value="${sku}"/>
        <dsp:oparam name="output">
          <dsp:setvalue param="theListPrice" paramvalue="price"/>
          <%-- Search for the sale price, if sale price list is defined for the current user. --%>
          <dsp:getvalueof var="profileSalePriceList" bean="Profile.salePriceList"/>
          <c:choose>
            <c:when test="${not empty profileSalePriceList}">
            
              <%-- Lookup the sale price. --%>
              <dsp:droplet name="PriceDroplet">
                <dsp:param name="priceList" bean="Profile.salePriceList"/>
                <dsp:oparam name="output">
                
                  <%-- Sale price found, display both list and sale prices. --%>
                  <dsp:getvalueof var="listPrice" vartype="java.lang.Double" param="price.listPrice"/>
                  <dsp:include page="/global/gadgets/formattedPrice.jsp">
                    <dsp:param name="price" value="${listPrice }"/>
                  </dsp:include>
                
                  <span class="atg_store_oldPrice">
                    <fmt:message key="common.price.old"/>
                    <dsp:getvalueof var="price" vartype="java.lang.Double" param="theListPrice.listPrice"/>
                    <del>
                      <dsp:include page="/global/gadgets/formattedPrice.jsp">
                        <dsp:param name="price" value="${price }"/>
                      </dsp:include>
                    </del>
                  </span>
                </dsp:oparam>
                <dsp:oparam name="empty">
                
                  <%-- Can't find sale price, display list price only. --%>
                  <dsp:getvalueof var="price" vartype="java.lang.Double" param="theListPrice.listPrice"/>
                  <dsp:include page="/global/gadgets/formattedPrice.jsp">
                    <dsp:param name="price" value="${price }"/>
                  </dsp:include>
                </dsp:oparam>
              </dsp:droplet>
            </c:when>
            <c:otherwise>
            
              <%-- No sale price list defined for the current user, display list price only. --%>
              <dsp:getvalueof var="price" vartype="java.lang.Double" param="theListPrice.listPrice"/>
              <dsp:include page="/global/gadgets/formattedPrice.jsp">
                <dsp:param name="price" value="${price }"/>
              </dsp:include>
            </c:otherwise>
          </c:choose>
        </dsp:oparam>
      </dsp:droplet>
    </c:when>
    <c:otherwise>
      <%-- PRICE RANGE --%>
      <dsp:importbean bean="/atg/commerce/pricing/PriceRangeDroplet"/>
    
      <dsp:getvalueof var="highestListPrice" param="highestListPrice"/>
      <dsp:getvalueof var="lowestListPrice" param="lowestListPrice"/>
      <dsp:getvalueof var="lowestPrice" param="lowestSalePrice"/>
      <dsp:getvalueof var="highestPrice" param="highestSalePrice"/>
      
      <%-- 
        PriceRangeDroplet is used to generate the highest and the lowest prices for
        a product based on its child SKUs.
    
        In this call to the PriceRangeDroplet, we override the salePriceList parameter
        with the shopper's standard price list (profile.priceList). In so doing, we
        force both the priceList and the salePriceList parameters to reference the
        standard price list. This effectively limits the calculation to take into 
        account only the standard prices. 
        
        For Example, if we have the following price lists for a product:
        listPrice: 100
        salePrice 80
    
        Sale price always wins if it exists, so we force the use of listPrice which will return
        highestPrice:100
        lowestPrice:100
    
        The same goes if a product has a price range, the range will only use the sale prices if
        they exist.
    
        Input Parameters:
          productId - The product repository id
      
          salePriceList - The sale price list
      
        Open Parameters:
          output - Rendered when no errors occur
      
        Output Parameters:
          highestListPrice - The highest price in the standard price list
      
          lowestListPrice - The lowest price in the standard price list
      --%>
      <c:if test="${empty highestListPrice || empty lowestListPrice }">   
        <dsp:droplet name="PriceRangeDroplet">
          <dsp:param name="productId" param="product.repositoryId"/>
          <dsp:param name="salePriceList" bean="Profile.priceList"/>
          <dsp:oparam name="output">
            <%-- The values of the range calculated from the standard pricelist. --%>
            <dsp:getvalueof var="highestListPrice" vartype="java.lang.Double" param="highestPrice"/>
            <dsp:getvalueof var="lowestListPrice" vartype="java.lang.Double" param="lowestPrice"/>
          </dsp:oparam>
        </dsp:droplet>
      </c:if>
  
      <%-- 
        PriceRangeDroplet is used to generate the highest and the lowest prices for
        a product based on its child SKUs.
    
        For the second call to the droplet, we want to use the sale prices 
        in the calculation, so we don't provide any parameter overrides. 
        This means PriceRangeDroplet uses its defaults, profile.priceList 
        and profile.salePriceList, to calculate the lowest and highest prices. 
    
        For Example, if we have the following price lists for a product:
        listPrice: 100
        salePrice 80
    
        Sale price always wins if it exists, so in this case we are returned
        highestPrice:80
        lowestPrice:80
    
        The same goes if a product has a price range, the range will only use the sale prices if
        they exist.
    
        Input Parameters:
          productId - The product repository id
      
        Open Parameters:
          output - rendered when no errors occur
      
        Output Parameters:
          highestPrice - The highest price in the sale price list
      
          lowestPrice - The lowest price in the sale price list
      --%>
      <c:if test="${empty highestPrice || empty lowestPrice }">  
        <dsp:droplet name="PriceRangeDroplet">
          <dsp:param name="productId" param="product.repositoryId"/>           
          <dsp:oparam name="output">
            <dsp:getvalueof var="highestPrice" vartype="java.lang.Double" param="highestPrice"/>
            <dsp:getvalueof var="lowestPrice" vartype="java.lang.Double" param="lowestPrice"/>
          </dsp:oparam>
        </dsp:droplet>
      </c:if>
  
      <%-- 
        Compare the values returned during the two calls to the PriceRangeDroplet. If they differ,
        it means that the sale price list returned a lower value than the standard price list, in 
        which case, the sale price range should be rendered along with the standard price range.
        
        Because we didnt overwrite the salePricelist in this PriceRangeDroplet call the highestPrice
        output parameter will be the highest price from the salePriceList if it exists, otherwise it
        will be the highest price from the standard priceList. The lowest price output parameter 
        will be the lowest price from the salePriceList if it exists, otherwise it will be the 
        lowest price from the standard priceList.
      --%>
      <c:if test="${highestListPrice != highestPrice || lowestListPrice != lowestPrice}">
        <c:set var="showSalePrice" value="true"/>        
      </c:if>

      <%--
        Compare prices to determine if we have a single price or a price range.
      --%>
      <c:choose>
        <c:when test="${lowestPrice eq highestPrice }">
          <dsp:include page="/global/gadgets/formattedPrice.jsp">
            <dsp:param name="price" value="${lowestPrice }"/>
          </dsp:include>
        </c:when>
        <c:otherwise>
          <dsp:include page="/global/gadgets/formattedPrice.jsp">
            <dsp:param name="price" value="${lowestPrice }"/>
          </dsp:include> -
          <dsp:include page="/global/gadgets/formattedPrice.jsp">
            <dsp:param name="price" value="${highestPrice }"/>
          </dsp:include>
        </c:otherwise>
      </c:choose> 
  
      <%-- 
        If the sale price was rendered, then also render the standard 
        price range.
      --%>
      <c:if test="${showSalePrice}">
    
        <%--
          Compare prices to determine if we have a single price or a price range.
        --%>
        <c:choose>
          <c:when test="${lowestListPrice eq highestListPrice }">
            <span class="atg_store_oldPrice">
              <fmt:message key="common.price.old"/>
              <del>
                <dsp:include page="/global/gadgets/formattedPrice.jsp">
                  <dsp:param name="price" value="${lowestListPrice }"/>
                </dsp:include>
              </del>
            </span>
          </c:when>
          <c:otherwise>
            <span class="atg_store_oldPrice">
              <fmt:message key="common.price.old"/>
              <del>
                <dsp:include page="/global/gadgets/formattedPrice.jsp">
                  <dsp:param name="price" value="${lowestListPrice }"/>
                </dsp:include> -
                <dsp:include page="/global/gadgets/formattedPrice.jsp">
                  <dsp:param name="price" value="${highestListPrice }"/>
                </dsp:include>
              </del>
            </span>
          </c:otherwise>
        </c:choose>    
      </c:if>
    
    </c:otherwise>
  </c:choose>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/global/gadgets/priceDisplay.jsp#1 $$Change: 848678 $--%>
