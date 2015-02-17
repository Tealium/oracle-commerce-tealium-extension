<%-- 
  This page lays out the elements that make up the search radius refinement menu.
    
  Required Parameters:
    contentItem
   
  Optional Parameters:
    None
--%>

<dsp:page>
 
  <dsp:getvalueof var="contextPath" vartype="java.lang.String"  bean="/OriginatingRequest.contextPath"/>
  <dsp:importbean bean="/OriginatingRequest" var="originatingRequest"/>
  <dsp:importbean bean="/atg/store/droplet/StoreUnitsOfMeasureConversionDroplet"/>
  
  <dsp:getvalueof var="contentItem" vartype="com.endeca.infront.assembler.ContentItem" value="${originatingRequest.contentItem}"/> 

  <dsp:getvalueof var="enabled" value="${contentItem.enabled}"/>
  <c:if test="${enabled}">
    <div class="atg_store_facetsGroup_options_catsub atg_store_geoFilter_refinement">
      <h5><fmt:message key="store.searchRadius.distance"/></h5>
      <div>
        <ul class="atg_store_facetOptions" dojoattachpoint="containerNode">
           <c:forEach var="radiusEntry" items="${contentItem.searchRadius}">
             <li>
               <%-- 
                 Determine locale based unit to be used and convert search radius 
                 to kilometer for use by endeca. 
                  
                 Input parameters:
                 value
                   search radius in unit as per shopper's locale
                 to
                   km: as endeca expects radius to be in kilometer.

                 Output parameters:
                   from
                     Unit used as per shopper's locale
                   result
                     search radius in kilometer to be sent to endeca
               --%> 
               <dsp:droplet name="StoreUnitsOfMeasureConversionDroplet">
                 <dsp:param name="value" value="${radiusEntry}"/> 
                 <dsp:param name="to" value="km"/>
                 <dsp:oparam name="output">
                   <dsp:getvalueof var="result" param="result"/>
                   <dsp:getvalueof var="from" param="from"/>
                   <dsp:a href="javascript:filterByNewRadius('${result}', '${contentItem.geoProperty}');" title="${radiusEntry}">
                     <c:out value="${radiusEntry}"/> 
                     <span class="productCount"><c:out value="${from}"/></span>
                   </dsp:a>
                 </dsp:oparam>
               </dsp:droplet>
             </li>
           </c:forEach>
        </ul>
      </div>
    </div>
  </c:if>

</dsp:page>
<script type="text/javascript" src="${pageContext.request.contextPath}/cartridges/LocationSearchRadius/js/searchRadius.js"></script> 
<%-- @version $Id: //hosting-blueprint/B2CBlueprint/version/11.0/Storefront/j2ee/store.war/cartridges/LocationSearchRadius/LocationSearchRadius.jsp#1 $--%>