<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mt-4">
    <h4>상품 관리</h4>

    <!-- 검색 -->
    <form action="<c:url value='/admin/gd/prdMng.do'/>" method="get" class="mb-4">
        <div class="row">
            <div class="col-md-3">
                <select name="prdStatCd" class="form-control">
                    <option value="">전체 상태</option>
                    <option value="30" <c:if test="${prdStatCd == '30'}">selected</c:if>>판매중</option>
                    <option value="40" <c:if test="${prdStatCd == '40'}">selected</c:if>>일시품절</option>
                    <option value="50" <c:if test="${prdStatCd == '50'}">selected</c:if>>예약판매</option>
                    <option value="90" <c:if test="${prdStatCd == '90'}">selected</c:if>>판매종료</option>
                </select>
            </div>
            <div class="col-md-4">
                <div class="input-group">
                    <input type="text" name="searchKeyword" class="form-control"
                           placeholder="상품명/상품코드 검색" value="<c:out value='${searchKeyword}'/>">
                    <div class="input-group-append">
                        <button type="submit" class="btn btn-primary">검색</button>
                    </div>
                </div>
            </div>
            <div class="col-md-2">
                <a href="<c:url value='/admin/gd/prdReg.do'/>" class="btn btn-success">상품 등록</a>
            </div>
        </div>
    </form>

    <!-- 총 건수 -->
    <p class="text-muted">총 <strong>${totalCnt}</strong>건</p>

    <!-- 상품 목록 테이블 -->
    <table class="table table-bordered table-hover">
        <thead class="thead-light">
            <tr>
                <th>상품코드</th>
                <th>상품명</th>
                <th>카테고리</th>
                <th>판매가</th>
                <th>재고</th>
                <th>상태</th>
                <th>등록일</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="prd" items="${prdList}">
                <tr>
                    <td><c:out value="${prd.prdCd}"/></td>
                    <td><a href="<c:url value='/admin/gd/prdReg.do?prdCd=${prd.prdCd}'/>"><c:out value="${prd.prdNm}"/></a></td>
                    <td><c:out value="${prd.lCatNm}"/></td>
                    <td class="text-right"><fmt:formatNumber value="${prd.salePrc}" pattern="#,###"/>원</td>
                    <td class="text-right">${prd.stockQty}</td>
                    <td>
                        <c:choose>
                            <c:when test="${prd.prdStatCd == '30'}"><span class="badge badge-success"><c:out value="${prd.prdStatNm}"/></span></c:when>
                            <c:when test="${prd.prdStatCd == '40'}"><span class="badge badge-danger"><c:out value="${prd.prdStatNm}"/></span></c:when>
                            <c:when test="${prd.prdStatCd == '50'}"><span class="badge badge-warning"><c:out value="${prd.prdStatNm}"/></span></c:when>
                            <c:when test="${prd.prdStatCd == '90'}"><span class="badge badge-secondary"><c:out value="${prd.prdStatNm}"/></span></c:when>
                            <c:otherwise><span class="badge badge-light"><c:out value="${prd.prdStatNm}"/></span></c:otherwise>
                        </c:choose>
                    </td>
                    <td><fmt:formatDate value="${prd.regDt}" pattern="yyyy-MM-dd"/></td>
                    <td>
                        <a href="<c:url value='/admin/gd/prdReg.do?prdCd=${prd.prdCd}'/>"
                           class="btn btn-sm btn-outline-primary">수정</a>
                        <c:if test="${prd.prdStatCd != '90'}">
                            <button type="button" class="btn btn-sm btn-outline-danger"
                                    onclick="deletePrd('${prd.prdCd}')">삭제</button>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty prdList}">
                <tr>
                    <td colspan="8" class="text-center py-4 text-muted">등록된 상품이 없습니다.</td>
                </tr>
            </c:if>
        </tbody>
    </table>

    <!-- 페이징 -->
    <c:if test="${totalCnt > 0}">
        <nav aria-label="Page navigation">
            <ul class="pagination justify-content-center">
                <c:if test="${startPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/admin/gd/prdMng.do?pageNo=${prevPage}&searchKeyword=${searchKeyword}&prdStatCd=${prdStatCd}'/>">&laquo;</a>
                    </li>
                </c:if>
                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item <c:if test='${i == pageNo}'>active</c:if>">
                        <a class="page-link" href="<c:url value='/admin/gd/prdMng.do?pageNo=${i}&searchKeyword=${searchKeyword}&prdStatCd=${prdStatCd}'/>">${i}</a>
                    </li>
                </c:forEach>
                <c:if test="${endPage < totalPage}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/admin/gd/prdMng.do?pageNo=${nextPage}&searchKeyword=${searchKeyword}&prdStatCd=${prdStatCd}'/>">&raquo;</a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </c:if>
</div>

<script>
function deletePrd(prdCd) {
    if (!confirm('해당 상품을 판매종료 처리하시겠습니까?')) return;

    $.ajax({
        url: '<c:url value="/admin/gd/deletePrd.do"/>',
        type: 'POST',
        data: { prdCd: prdCd },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS') {
                alert(data.rtnMsg);
                location.reload();
            } else {
                alert(data.rtnMsg || '오류가 발생했습니다.');
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}
</script>
