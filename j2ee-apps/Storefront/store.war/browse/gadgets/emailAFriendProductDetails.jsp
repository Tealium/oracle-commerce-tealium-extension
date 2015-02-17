<%--
  This page renders brief product details about the product being emailed.
  
  Details include:
    product image.
    product name.
    product price.
    product description.
  
  Required Parameters: 
    product
      Repository item of the product being emailed about.
--%>

<dsp:page>

  <dsp:importbean bean="/atg/dynamo/droplet/Compare"/>
  
  <%-- ************************* begin product description ************************* --%>
  <div class="atg_store_emailProduct">
    <%-- Show basic information --%>
      <div class="atg_store_productImage">
        <dsp:include page="/browse/gadgets/productImg.jsp">
          <dsp:param name="showAsLink" value="false"/>
          <dsp:param name="image" param="product.smallImage"/>     
          <dsp:param name="defaultImageSize" value="small"/>     
        </dsp:include>
      </div>
    
      <div class="atg_store_productInfo">
        <div class="atg_store_productTitle">
          <dsp:include page="/browse/gadgets/productName.jsp">
            <dsp:param name="showAsLink" value="false"/>
          </dsp:include>
        </div>
        
        <div class="atg_store_emailProductPrice">
          <dsp:include page="/global/gadgets/priceDisplay.jsp">
            <dsp:param name="product" param="product"/>   
          </dsp:include>
        </div>
        
        <div class="atg_store_productDescription">
          <p>
            <dsp:valueof param="product.longDescription" valueishtml="true"/>
          </p>
        </div>
      </div>
    </div>
  <%-- ************************* end product description ************************* --%>

</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/browse/gadgets/emailAFriendProductDetails.jsp#1 $$Change: 848678 $--%>
