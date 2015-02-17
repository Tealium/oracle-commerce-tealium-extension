<%--
  This gadget renders both JS and non-JS versions of color/size picker.

  Required parameters:
    product
      Currentrly viewed product.
    skus
      Collection of product's SKUs.

  Optional parameters:
    categoryId
      ID of category product is viewed from.
--%>

<dsp:page>
  <%-- Include JS picker version. --%>
  <dsp:include page="gadgets/pickerContents.jsp">
    <dsp:param name="productId" param="product.repositoryId"/>
    <dsp:param name="categoryId" param="categoryId"/>
  </dsp:include>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/browse/pickerColorSizeContainer.jsp#1 $$Change: 848678 $--%>
