<dsp:page>
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}" />

  <div class="shadowTopDown"></div>
  <%-- Display the slider --%>
  <dsp:include page="${mobileStorePrefix}/global/gadgets/productsHorizontalList.jsp">
    <dsp:param name="products" value="${contentItem['atg:contents'].items}" />
    <dsp:param name="itemDetail" value="true" />
  </dsp:include>

</dsp:page>
