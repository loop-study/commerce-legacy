<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container mt-4">
    <h4 class="mb-4">주문내역</h4>

    <!-- 기간 검색 -->
    <div class="mb-3">
        <div class="btn-group" role="group">
            <a href="<c:url value='/my/order/myOrderList.do?searchPeriod=1'/>"
               class="btn btn-sm ${searchPeriod == '1' ? 'btn-primary' : 'btn-outline-primary'}">1개월</a>
            <a href="<c:url value='/my/order/myOrderList.do?searchPeriod=3'/>"
               class="btn btn-sm ${searchPeriod == '3' ? 'btn-primary' : 'btn-outline-primary'}">3개월</a>
            <a href="<c:url value='/my/order/myOrderList.do?searchPeriod=6'/>"
               class="btn btn-sm ${searchPeriod == '6' ? 'btn-primary' : 'btn-outline-primary'}">6개월</a>
            <a href="<c:url value='/my/order/myOrderList.do'/>"
               class="btn btn-sm ${empty searchPeriod ? 'btn-primary' : 'btn-outline-primary'}">전체</a>
        </div>
        <span class="ml-3 text-muted">총 <strong>${totalCnt}</strong>건</span>
    </div>

    <c:choose>
        <c:when test="${not empty orderList}">
            <c:forEach var="order" items="${orderList}">
                <div class="card mb-3">
                    <div class="card-header d-flex justify-content-between align-items-center py-2">
                        <div>
                            <strong><c:out value="${order.ordDt}"/></strong>
                            <span class="text-muted ml-2">주문번호: <c:out value="${order.ordNo}"/></span>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${order.ordStatCd == '50'}">
                                    <span class="badge badge-success"><c:out value="${order.ordStatNm}"/></span>
                                </c:when>
                                <c:when test="${order.ordStatCd == '90'}">
                                    <span class="badge badge-danger"><c:out value="${order.ordStatNm}"/></span>
                                </c:when>
                                <c:when test="${order.ordStatCd == '40'}">
                                    <span class="badge badge-warning"><c:out value="${order.ordStatNm}"/></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-info"><c:out value="${order.ordStatNm}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="card-body py-3">
                        <div class="row align-items-center">
                            <div class="col-auto">
                                <div class="bg-light text-center" style="width:60px; height:60px; line-height:60px;">
                                    <c:choose>
                                        <c:when test="${not empty order.imgPath}">
                                            <img src="<c:url value='${order.imgPath}'/>" alt="<c:out value='${order.firstPrdNm}'/>"
                                                 style="max-height:60px; max-width:60px;"
                                                 onerror="this.parentElement.innerHTML='No Image'">
                                        </c:when>
                                        <c:otherwise><small class="text-muted">No Image</small></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="col">
                                <strong><c:out value="${order.firstPrdNm}"/></strong>
                                <c:if test="${order.dtlCnt > 1}">
                                    <span class="text-muted"> 외 ${order.dtlCnt - 1}건</span>
                                </c:if>
                                <br>
                                <small class="text-muted">
                                    <c:out value="${order.payTpNm}"/> | 받는분: <c:out value="${order.reciverNm}"/>
                                </small>
                                <c:if test="${not empty order.invoiceNo}">
                                    <br>
                                    <small class="text-primary">
                                        <c:out value="${order.delvCoNm}"/> <c:out value="${order.invoiceNo}"/>
                                    </small>
                                </c:if>
                            </div>
                            <div class="col-auto text-right">
                                <strong class="h5">
                                    <fmt:formatNumber value="${order.payAmt}" pattern="#,###"/>원
                                </strong>
                                <br>
                                <a href="<c:url value='/my/order/myOrderDtl.do?ordNo=${order.ordNo}'/>"
                                   class="btn btn-sm btn-outline-secondary mt-1">상세보기</a>
                                <c:if test="${order.ordStatCd == '10' or order.ordStatCd == '20'}">
                                    <button type="button" class="btn btn-sm btn-outline-danger mt-1"
                                            onclick="cancelMyOrder('<c:out value="${order.ordNo}"/>')">주문취소</button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <!-- 페이징 -->
            <c:if test="${totalPage > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <c:if test="${prevPage > 0}">
                            <li class="page-item">
                                <a class="page-link" href="<c:url value='/my/order/myOrderList.do?pageNo=${prevPage}&searchPeriod=${searchPeriod}'/>">&laquo;</a>
                            </li>
                        </c:if>
                        <c:forEach var="i" begin="${startPage}" end="${endPage}">
                            <li class="page-item ${i == pageNo ? 'active' : ''}">
                                <a class="page-link" href="<c:url value='/my/order/myOrderList.do?pageNo=${i}&searchPeriod=${searchPeriod}'/>">${i}</a>
                            </li>
                        </c:forEach>
                        <c:if test="${nextPage > 0}">
                            <li class="page-item">
                                <a class="page-link" href="<c:url value='/my/order/myOrderList.do?pageNo=${nextPage}&searchPeriod=${searchPeriod}'/>">&raquo;</a>
                            </li>
                        </c:if>
                    </ul>
                </nav>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5">
                <p class="text-muted mb-4">주문내역이 없습니다.</p>
                <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-primary">상품 보러가기</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
function cancelMyOrder(ordNo) {
    if (!confirm('주문을 취소하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: '<c:url value="/my/order/cancelMyOrder.do"/>',
        type: 'POST',
        data: { ordNo: ordNo },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'LOGIN_REQUIRED') {
                alert('로그인이 필요합니다.');
                location.href = '<c:url value="/login.do"/>';
                return;
            }
            alert(data.rtnMsg);
            if (data.rtnCode === 'SUCCESS') {
                location.reload();
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}
</script>