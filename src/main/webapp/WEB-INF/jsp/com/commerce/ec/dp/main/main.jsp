<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mt-4">
    <!-- 카테고리 영역 -->
    <div class="mb-4">
        <h4>카테고리</h4>
        <div class="d-flex flex-wrap">
            <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-secondary btn-sm mr-2 mb-2">전체</a>
            <c:forEach var="cat" items="${catList}">
                <a href="<c:url value='/dp/good/prdList.do?lCatCd=${cat.catCd}'/>"
                   class="btn btn-outline-secondary btn-sm mr-2 mb-2"><c:out value="${cat.catNm}"/></a>
            </c:forEach>
        </div>
    </div>

    <!-- 최신 상품 목록 -->
    <div class="mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>신상품</h4>
            <a href="<c:url value='/dp/good/prdList.do'/>" class="text-muted">더보기 &gt;</a>
        </div>
        <div class="row">
            <c:forEach var="prd" items="${newPrdList}">
                <div class="col-md-3 mb-4">
                    <div class="card h-100">
                        <div class="card-img-top bg-light text-center" style="height:200px; line-height:200px;">
                            <c:choose>
                                <c:when test="${not empty prd.imgPath}">
                                    <img src="<c:url value='${prd.imgPath}'/>" alt="<c:out value='${prd.prdNm}'/>"
                                         style="max-height:200px; max-width:100%;"
                                         onerror="this.parentElement.innerHTML='No Image'">
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">No Image</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="card-body">
                            <span class="badge badge-info mb-1"><c:out value="${prd.lCatNm}"/></span>
                            <h6 class="card-title">
                                <a href="<c:url value='/dp/good/prdDtl.do?prdCd=${prd.prdCd}'/>" class="text-dark">
                                    <c:out value="${prd.prdNm}"/>
                                </a>
                            </h6>
                            <p class="card-text text-muted small"><c:out value="${prd.smplDesc}"/></p>
                            <p class="card-text font-weight-bold">
                                <fmt:formatNumber value="${prd.salePrc}" pattern="#,###"/>원
                            </p>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty newPrdList}">
                <div class="col-12 text-center py-5">
                    <p class="text-muted">등록된 상품이 없습니다.</p>
                </div>
            </c:if>
        </div>
    </div>
</div>