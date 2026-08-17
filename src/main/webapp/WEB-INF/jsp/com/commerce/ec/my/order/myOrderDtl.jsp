<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">주문 상세</h4>
        <a href="<c:url value='/my/order/myOrderList.do'/>" class="btn btn-outline-secondary btn-sm">주문내역으로</a>
    </div>

    <!-- 주문 정보 -->
    <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
            <strong>주문 정보</strong>
            <c:choose>
                <c:when test="${orderInfo.ordStatCd == '50'}">
                    <span class="badge badge-success"><c:out value="${orderInfo.ordStatNm}"/></span>
                </c:when>
                <c:when test="${orderInfo.ordStatCd == '90'}">
                    <span class="badge badge-danger"><c:out value="${orderInfo.ordStatNm}"/></span>
                </c:when>
                <c:when test="${orderInfo.ordStatCd == '40'}">
                    <span class="badge badge-warning"><c:out value="${orderInfo.ordStatNm}"/></span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-info"><c:out value="${orderInfo.ordStatNm}"/></span>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="card-body">
            <table class="table table-borderless mb-0">
                <tr>
                    <th class="w-25 text-muted">주문번호</th>
                    <td><c:out value="${orderInfo.ordNo}"/></td>
                </tr>
                <tr>
                    <th class="text-muted">주문일시</th>
                    <td><c:out value="${orderInfo.ordDt}"/></td>
                </tr>
                <tr>
                    <th class="text-muted">결제수단</th>
                    <td><c:out value="${orderInfo.payTpNm}"/></td>
                </tr>
                <c:if test="${not empty orderInfo.pgAprvNo}">
                    <tr>
                        <th class="text-muted">승인번호</th>
                        <td><c:out value="${orderInfo.pgAprvNo}"/></td>
                    </tr>
                </c:if>
                <tr>
                    <th class="text-muted">결제금액</th>
                    <td>
                        <strong class="h5"><fmt:formatNumber value="${orderInfo.payAmt}" pattern="#,###"/>원</strong>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <!-- 무통장입금 안내 (무통장 + 입금 전 상태) -->
    <c:if test="${orderInfo.payTpCd == '10' and orderInfo.ordStatCd == '10'}">
        <div class="card border-primary mb-4">
            <div class="card-header bg-primary text-white"><strong>입금 안내</strong></div>
            <div class="card-body">
                <table class="table table-borderless mb-2">
                    <tr>
                        <th class="w-25 text-muted">입금 계좌</th>
                        <td>
                            <strong><c:out value="${bankNm}"/> <c:out value="${bankAccount}"/></strong>
                            <span class="text-muted">(예금주 : <c:out value="${bankHolder}"/>)</span>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-muted">입금 금액</th>
                        <td>
                            <strong class="text-danger h5">
                                <fmt:formatNumber value="${orderInfo.payAmt}" pattern="#,###"/>원
                            </strong>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-muted">입금자명</th>
                        <td><c:out value="${orderInfo.depositorNm}"/></td>
                    </tr>
                    <tr>
                        <th class="text-muted">입금 기한</th>
                        <td><c:out value="${orderInfo.payLimitDt}"/> <span class="text-muted">까지</span></td>
                    </tr>
                </table>
                <p class="text-muted small mb-0">
                    · 입금 기한까지 미입금 시 주문이 자동 취소될 수 있습니다.<br>
                    · 입금이 확인되면 주문 상태가 결제완료로 변경됩니다.
                </p>
            </div>
        </div>
    </c:if>

    <!-- 주문 상품 -->
    <div class="card mb-4">
        <div class="card-header"><strong>주문 상품</strong></div>
        <div class="card-body p-0">
            <table class="table mb-0">
                <thead class="thead-light">
                    <tr>
                        <th style="width:80px"></th>
                        <th>상품정보</th>
                        <th class="text-right" style="width:110px">판매가</th>
                        <th class="text-right" style="width:100px">할인</th>
                        <th class="text-center" style="width:80px">수량</th>
                        <th class="text-right" style="width:120px">주문금액</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="prd" items="${orderPrdList}">
                        <tr>
                            <td>
                                <div class="bg-light text-center" style="width:60px; height:60px; line-height:60px;">
                                    <c:choose>
                                        <c:when test="${not empty prd.imgPath}">
                                            <img src="<c:url value='${prd.imgPath}'/>" alt="<c:out value='${prd.prdNm}'/>"
                                                 style="max-height:60px; max-width:60px;"
                                                 onerror="this.parentElement.innerHTML='No Image'">
                                        </c:when>
                                        <c:otherwise><small class="text-muted">No Image</small></c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td class="align-middle">
                                <a href="<c:url value='/dp/good/prdDtl.do?prdCd=${prd.prdCd}'/>" class="text-dark">
                                    <strong><c:out value="${prd.prdNm}"/></strong>
                                </a>
                                <c:if test="${not empty prd.smplDesc}">
                                    <br><small class="text-muted"><c:out value="${prd.smplDesc}"/></small>
                                </c:if>
                            </td>
                            <td class="text-right align-middle">
                                <fmt:formatNumber value="${prd.salePrc}" pattern="#,###"/>원
                            </td>
                            <td class="text-right align-middle">
                                <c:choose>
                                    <c:when test="${prd.discAmt > 0}">
                                        <span class="text-danger">-<fmt:formatNumber value="${prd.discAmt}" pattern="#,###"/>원</span>
                                    </c:when>
                                    <c:otherwise><span class="text-muted">-</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center align-middle">${prd.ordQty}</td>
                            <td class="text-right align-middle font-weight-bold">
                                <fmt:formatNumber value="${prd.ordAmt}" pattern="#,###"/>원
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 배송 정보 -->
    <div class="card mb-4">
        <div class="card-header"><strong>배송 정보</strong></div>
        <div class="card-body">
            <table class="table table-borderless mb-0">
                <tr>
                    <th class="w-25 text-muted">받는분</th>
                    <td><c:out value="${orderInfo.reciverNm}"/></td>
                </tr>
                <tr>
                    <th class="text-muted">연락처</th>
                    <td><c:out value="${orderInfo.delvHpNo}"/></td>
                </tr>
                <tr>
                    <th class="text-muted">배송지</th>
                    <td>
                        (<c:out value="${orderInfo.delvZipcode}"/>)
                        <c:out value="${orderInfo.delvBaseAddr}"/> <c:out value="${orderInfo.delvDtlAddr}"/>
                    </td>
                </tr>
                <c:if test="${not empty orderInfo.delvMsg}">
                    <tr>
                        <th class="text-muted">배송메모</th>
                        <td><c:out value="${orderInfo.delvMsg}"/></td>
                    </tr>
                </c:if>
                <c:if test="${not empty orderInfo.invoiceNo}">
                    <tr>
                        <th class="text-muted">송장번호</th>
                        <td>
                            <c:out value="${orderInfo.delvCoNm}"/>
                            <strong><c:out value="${orderInfo.invoiceNo}"/></strong>
                        </td>
                    </tr>
                </c:if>
            </table>
        </div>
    </div>

    <!-- 하단 버튼 -->
    <div class="text-center mb-5">
        <a href="<c:url value='/my/order/myOrderList.do'/>" class="btn btn-outline-secondary btn-lg mr-2">목록</a>
        <c:if test="${orderInfo.ordStatCd == '10' or orderInfo.ordStatCd == '20'}">
            <button type="button" class="btn btn-outline-danger btn-lg"
                    onclick="cancelMyOrder('<c:out value="${orderInfo.ordNo}"/>')">주문취소</button>
        </c:if>
    </div>
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
