<%--
  This gadget lists the user's saved Credit Cards.

  Page includes:
    /mobile/creditcard/gadgets/creditCardRenderer.jsp - Credit card data renderer

  Required parameters:
    page
      'myaccount' = This page is called in "My Account" context
      'checkout' = This page is called in "Checkout" context
    selectable
      Indicates if rendered items can be selected by user

  Optional parameters:
    displayDefaultLabeled
      Indicates if default credit card is marked with 'Default' label
      NOTE: can be used only if 'selectable' parameter is false
    selectProperty
      formHandler property that should store selected card key
      NOTE: makes sense only if 'selectable' parameter is true
      Default value: BillingFormHandler.storedCreditCardName

  NOTES:
    1) The "mobileStorePrefix" request-scoped variable (request attribute), which is used here,
       is defined in the "mobilePageContainer" tag ("mobilePageContainer.tag" file).
       This variable becomes available within the <crs:mobilePageContainer> ... </crs:mobilePageContainer> block
       and in all the included pages (gadgets and Endeca cartridges).
--%>
<dsp:page>
  <dsp:importbean bean="/atg/commerce/util/MapToArrayDefaultFirst"/>
  <dsp:importbean bean="/atg/store/mobile/order/purchase/BillingFormHandler"/>
  <dsp:importbean bean="/atg/userprofiling/ProfileFormHandler"/>
  <dsp:importbean bean="/atg/userprofiling/Profile"/>

  <%-- Request parameters - to variables --%>
  <dsp:getvalueof var="page" param="page"/>
  <dsp:getvalueof var="selectableMode" param="selectable"/>
  <dsp:getvalueof var="displayDefaultLabeled" param="displayDefaultLabeled"/>
  <dsp:getvalueof var="selectProperty" param="selectProperty"/>
  <c:if test="${not empty selectableMode and empty selectProperty}">
    <c:set var="selectProperty" value="BillingFormHandler.storedCreditCardName"/>
  </c:if>

  <dsp:getvalueof var="defaultCardId" bean="Profile.defaultCreditCard.repositoryId"/>

  <ul id="creditCardList" class="dataList">
    <%-- Check if the profile has credit cards and show them --%>
    <dsp:getvalueof var="creditCards" bean="Profile.creditCards"/>
    <c:if test="${not empty creditCards}">
      <%-- Get all saved credit cards, display default card first, then sort other cards by title --%>
      <dsp:droplet name="MapToArrayDefaultFirst">
        <dsp:param name="map" bean="Profile.creditCards"/>
        <c:if test="${not empty defaultCardId}">
          <dsp:param name="defaultId" value="${defaultCardId}"/>
        </c:if>
        <dsp:param name="sortByKeys" value="true"/>
        <dsp:oparam name="output">
          <dsp:getvalueof var="sortedArray" param="sortedArray"/>
          <c:if test="${not empty sortedArray}">
            <%-- Display all saved credit cards --%>
            <c:forEach var="userCard" items="${sortedArray}" varStatus="status">
              <dsp:param name="userCard" value="${userCard}"/>
              <c:if test="${not empty userCard}">
              
                <dsp:getvalueof var="expirationYear" param="userCard.value.expirationYear"/>
                <dsp:getvalueof var="expirationMonth" param="userCard.value.expirationMonth"/>
                <jsp:useBean id="date" class="java.util.Date" />
                <fmt:formatDate value="${date}" pattern="yyyyMM" var="currentYearMonth" />
                <fmt:formatDate value="${expirationMonth}/1/${expirationYear}" pattern="yyyyMM" var="expirationYearMonth"/>
                <c:set var="expired" value="${expirationYearMonth < currentYearMonth}"/>
                <li class="${not empty errorCard && errorCard == userCard.value.id ? 'errorState' : ''} ${expired == true ? 'expiredCard' : ''}">
                  <div class="content">
                    <c:choose>
                      <%-- If card is expired, do not let it be selected --%>
                      <c:when test="${expired == 'true'}">
                        <dsp:input type="radio" value="${userCard.key}" name="creditcard" onclick="this.checked=false;"
                                  id="savedCreditCard${status.count}" checked="false" bean="${selectProperty}"/>
                      </c:when>
                      <c:when test="${selectableMode != 'false' && expired == 'false'}">
                        <dsp:input type="radio" value="${userCard.key}" name="creditcard"
                                  id="savedCreditCard${status.count}" checked="false" bean="${selectProperty}"/>
                      </c:when>
                    </c:choose>

                    <%-- Display Credit Card key --%>
                    <label for="savedCreditCard${status.count}" onclick="">
                      <span>
                        <c:out value="${userCard.key}"/>  
                      </span>

                      <dsp:include page="creditCardRenderer.jsp">
                        <dsp:param name="creditCard" param="userCard.value"/>
                      </dsp:include>
                      <%-- "Is Default" (default credit card goes FIRST) --%>
                      <c:if test="${displayDefaultLabeled == 'true'}">
                        <c:set var="isDefaultCard" value="${status.index == 0 && not empty defaultCardId}"/>
                      </c:if>
                      <c:if test="${isDefaultCard == 'true'}">
                        <span class="defaultLabel"><fmt:message key="mobile.common.label.default"/></span>
                      </c:if>
                    </label>

                    <%-- Display edit link --%>
                    <fmt:message var="editLinkTitle" key="mobile.creditcard.link.editCard"/>
                    <dsp:a bean="ProfileFormHandler.editCard"
                           page="../editCreditCard.jsp?page=${page}" paramvalue="userCard.key" title="${editLinkTitle}" class="icon-BlueArrow"/>
                  </div>
                  <c:if test="${not empty errorCard && errorCard == userCard.value.id}">
                    <span class="errorMessage">
                      <fmt:message key="mobile.common.error.missingBillingAddress"/>
                    </span>
                  </c:if>
                  <c:if test="${expired == 'true'}">
                    <span class="expiredLabel errorMessage"><fmt:message key="mobile.common.label.expired"/></span>
                    <span class="expiredError errorMessage" style="display: none;"><fmt:message key="mobile.creditcard.error.expired"/></span>
                  </c:if>
                </li>
              </c:if>
            </c:forEach>
          </c:if>
        </dsp:oparam>
      </dsp:droplet>
    </c:if>

    <%-- Link to "Add Credit Card" --%>
    <li id="newItemLI">
      <dsp:a page="${mobileStorePrefix}/${page}/newCreditCard.jsp" class="icon-ArrowRight">
        <span class="content"><fmt:message key="mobile.creditcard.newCreditCard"/></span>
      </dsp:a>
    </li>
  </ul>
</dsp:page>
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/mobile/creditcard/gadgets/savedCreditCards.jsp#1 $$Change: 848678 $--%>
