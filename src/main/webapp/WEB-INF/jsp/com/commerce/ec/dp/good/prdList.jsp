<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mt-4">
    <h4>상품 목록</h4>

    <!-- 검색 + 카테고리 필터 -->
    <form id="searchForm" action="<c:url value='/dp/good/prdList.do'/>" method="get" class="mb-4">
        <div class="row">
            <div class="col-md-2">
                <select name="lCatCd" class="form-control" id="lCatCdSelect" onchange="changeLCat();">
                    <option value="">전체 카테고리</option>
                    <c:forEach var="cat" items="${catList}">
                        <option value="${cat.catCd}" <c:if test="${cat.catCd == lCatCd}">selected</c:if>><c:out value="${cat.catNm}"/></option>
                    </c:forEach>
                </select>
            </div>
            <c:if test="${not empty mCatList}">
                <div class="col-md-2">
                    <select name="mCatCd" class="form-control" onchange="changeMCat();">
                        <option value="">전체 중카테고리</option>
                        <c:forEach var="mCat" items="${mCatList}">
                            <option value="${mCat.catCd}" <c:if test="${mCat.catCd == mCatCd}">selected</c:if>><c:out value="${mCat.catNm}"/></option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>
            <c:if test="${not empty sCatList}">
                <div class="col-md-2">
                    <select name="sCatCd" class="form-control" onchange="this.form.submit();">
                        <option value="">전체 소카테고리</option>
                        <c:forEach var="sCat" items="${sCatList}">
                            <option value="${sCat.catCd}" <c:if test="${sCat.catCd == sCatCd}">selected</c:if>><c:out value="${sCat.catNm}"/></option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>
            <div class="col-md-3">
                <div class="input-group">
                    <input type="text" name="searchKeyword" class="form-control"
                           placeholder="상품명 검색" value="<c:out value='${searchKeyword}'/>">
                    <div class="input-group-append">
                        <button type="submit" class="btn btn-primary">검색</button>
                    </div>
                </div>
            </div>
            <!-- 정렬 -->
            <div class="col-md-2">
                <select name="sortTp" class="form-control" onchange="this.form.submit();">
                    <option value="">최신순</option>
                    <option value="lowPrc" <c:if test="${sortTp == 'lowPrc'}">selected</c:if>>낮은가격순</option>
                    <option value="highPrc" <c:if test="${sortTp == 'highPrc'}">selected</c:if>>높은가격순</option>
                    <option value="prdNm" <c:if test="${sortTp == 'prdNm'}">selected</c:if>>상품명순</option>
                </select>
            </div>
        </div>
    </form>

    <!-- 총 건수 -->
    <p class="text-muted">총 <strong>${totalCnt}</strong>건</p>

    <!-- 상품 목록 -->
    <div class="row">
        <c:forEach var="prd" items="${prdList}">
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
                        <c:if test="${prd.prdStatCd == '40'}">
                            <span class="badge badge-danger mb-1">일시품절</span>
                        </c:if>
                        <c:if test="${prd.prdStatCd == '50'}">
                            <span class="badge badge-warning mb-1">예약판매</span>
                        </c:if>
                        <h6 class="card-title">
                            <a href="<c:url value='/dp/good/prdDtl.do?prdCd=${prd.prdCd}'/>" class="text-dark">
                                <c:out value="${prd.prdNm}"/>
                            </a>
                        </h6>
                        <p class="card-text text-muted small"><c:out value="${prd.smplDesc}"/></p>
                        <p class="card-text font-weight-bold">
                            <fmt:formatNumber value="${prd.salePrc}" pattern="#,###"/>원
                        </p>
                        <c:if test="${prd.cashDiscPrc > 0 and prd.cashDiscPrc < prd.salePrc}">
                            <small class="text-danger">현금할인가 <fmt:formatNumber value="${prd.cashDiscPrc}" pattern="#,###"/>원</small>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
        <c:if test="${empty prdList}">
            <div class="col-12 text-center py-5">
                <p class="text-muted">조건에 맞는 상품이 없습니다.</p>
            </div>
        </c:if>
    </div>

    <!-- 페이징 -->
    <c:if test="${totalCnt > 0}">
        <nav aria-label="Page navigation">
            <ul class="pagination justify-content-center">
                <c:if test="${startPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/dp/good/prdList.do?pageNo=${prevPage}&lCatCd=${lCatCd}&mCatCd=${mCatCd}&sCatCd=${sCatCd}&searchKeyword=${searchKeyword}&sortTp=${sortTp}'/>">&laquo;</a>
                    </li>
                </c:if>
                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item <c:if test='${i == pageNo}'>active</c:if>">
                        <a class="page-link" href="<c:url value='/dp/good/prdList.do?pageNo=${i}&lCatCd=${lCatCd}&mCatCd=${mCatCd}&sCatCd=${sCatCd}&searchKeyword=${searchKeyword}&sortTp=${sortTp}'/>">${i}</a>
                    </li>
                </c:forEach>
                <c:if test="${endPage < totalPage}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/dp/good/prdList.do?pageNo=${nextPage}&lCatCd=${lCatCd}&mCatCd=${mCatCd}&sCatCd=${sCatCd}&searchKeyword=${searchKeyword}&sortTp=${sortTp}'/>">&raquo;</a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </c:if>
</div>

<script>
/* 대카테고리 변경 : 중/소 카테고리 선택값 초기화 */
function changeLCat() {
    var f = document.getElementById('searchForm');
    if (f.mCatCd) f.mCatCd.value = '';
    if (f.sCatCd) f.sCatCd.value = '';
    f.submit();
}

/* 중카테고리 변경 : 소카테고리 선택값 초기화 */
function changeMCat() {
    var f = document.getElementById('searchForm');
    if (f.sCatCd) f.sCatCd.value = '';
    f.submit();
}
</script>
