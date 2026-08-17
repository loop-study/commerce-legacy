<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container mt-4">
    <c:choose>
        <c:when test="${not empty orderInfo}">
            <div class="text-center mb-4">
                <h4>주문이 완료되었습니다</h4>
                <p class="text-muted">주문번호: <strong><c:out value="${orderInfo.ordNo}"/></strong></p>
            </div>

            <!-- 무통장입금 안내 (무통장입금 + 입금 전(주문확인) 상태에서만 노출) -->
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
                                <td>
                                    <c:out value="${orderInfo.payLimitDt}"/>
                                    <span class="text-muted">까지</span>
                                </td>
                            </tr>
                        </table>
                        <p class="text-muted small mb-0">
                            · 입금 기한까지 미입금 시 주문이 자동 취소될 수 있습니다.<br>
                            · 입금자명이 다른 경우 입금 확인이 지연될 수 있습니다.<br>
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
                                <th class="text-center" style="width:100px">수량</th>
                                <th class="text-right" style="width:120px">금액</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="dtl" items="${orderDtlList}">
                                <tr>
                                    <td>
                                        <div class="bg-light text-center" style="width:60px; height:60px; line-height:60px;">
                                            <c:choose>
                                                <c:when test="${not empty dtl.imgPath}">
                                                    <img src="<c:url value='${dtl.imgPath}'/>" alt="<c:out value='${dtl.prdNm}'/>"
                                                         style="max-height:60px; max-width:60px;"
                                                         onerror="this.parentElement.innerHTML='No Image'">
                                                </c:when>
                                                <c:otherwise><small class="text-muted">No Image</small></c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <strong><c:out value="${dtl.prdNm}"/></strong>
                                        <c:if test="${not empty dtl.smplDesc}">
                                            <br><small class="text-muted"><c:out value="${dtl.smplDesc}"/></small>
                                        </c:if>
                                    </td>
                                    <td class="text-center align-middle">${dtl.ordQty}개</td>
                                    <td class="text-right align-middle font-weight-bold">
                                        <fmt:formatNumber value="${dtl.ordAmt}" pattern="#,###"/>원
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
                                (<c:out value="${orderInfo.delvZipcode}"/>) <c:out value="${orderInfo.delvBaseAddr}"/> <c:out value="${orderInfo.delvDtlAddr}"/>
                            </td>
                        </tr>
                        <c:if test="${not empty orderInfo.invoiceNo}">
                            <tr>
                                <th class="text-muted">송장번호</th>
                                <td>
                                    <c:out value="${orderInfo.delvCoNm}"/>
                                    <strong><c:out value="${orderInfo.invoiceNo}"/></strong>
                                </td>
                            </tr>
                        </c:if>
                        <c:if test="${not empty orderInfo.delvMsg}">
                            <tr>
                                <th class="text-muted">배송메모</th>
                                <td><c:out value="${orderInfo.delvMsg}"/></td>
                            </tr>
                        </c:if>
                    </table>
                </div>
            </div>

            <!-- 결제 정보 -->
            <div class="card mb-4">
                <div class="card-header"><strong>결제 정보</strong></div>
                <div class="card-body">
                    <table class="table table-borderless mb-0">
                        <tr>
                            <th class="w-25 text-muted">결제수단</th>
                            <td><c:out value="${orderInfo.payTpNm}"/></td>
                        </tr>
                        <tr>
                            <th class="text-muted">주문상태</th>
                            <td><span class="badge badge-info"><c:out value="${orderInfo.ordStatNm}"/></span></td>
                        </tr>
                        <tr>
                            <th class="text-muted">결제금액</th>
                            <td class="font-weight-bold text-primary h5">
                                <fmt:formatNumber value="${orderInfo.payAmt}" pattern="#,###"/>원
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <div class="text-center mb-4">
                <a href="<c:url value='/my/order/myOrderList.do'/>" class="btn btn-outline-primary btn-lg mr-2">주문내역 보기</a>
                <a href="<c:url value='/main.do'/>" class="btn btn-primary btn-lg">메인으로</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5">
                <p class="text-muted">주문 정보를 찾을 수 없습니다.</p>
                <a href="<c:url value='/main.do'/>" class="btn btn-outline-primary">메인으로</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
