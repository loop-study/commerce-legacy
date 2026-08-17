<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container mt-4">
    <h4 class="mb-4">장바구니</h4>

    <c:choose>
        <c:when test="${not empty cartList}">
            <table class="table">
                <thead class="thead-light">
                    <tr>
                        <th style="width:40px" class="text-center">
                            <input type="checkbox" id="allChk" onclick="checkAllCart(this)" checked>
                        </th>
                        <th style="width:80px"></th>
                        <th>상품정보</th>
                        <th style="width:120px" class="text-center">판매가</th>
                        <th style="width:120px" class="text-center">수량</th>
                        <th style="width:120px" class="text-center">합계</th>
                        <th style="width:80px" class="text-center">삭제</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cart" items="${cartList}" varStatus="status">
                        <tr data-cart-no="${cart.cartNo}" data-prd-cd="${cart.prdCd}"
                            data-sale-prc="${cart.salePrc}" data-max-qty="${cart.stockQty}">
                            <td class="text-center align-middle">
                                <%-- 일시품절(40) 상품은 주문 대상에서 제외 --%>
                                <input type="checkbox" class="cart-chk" value="${cart.cartNo}"
                                       onclick="calcTotal()"
                                       <c:if test="${cart.prdStatCd != '40'}">checked</c:if>
                                       <c:if test="${cart.prdStatCd == '40'}">disabled</c:if>>
                            </td>
                            <td>
                                <div class="bg-light text-center" style="width:70px; height:70px; line-height:70px;">
                                    <c:choose>
                                        <c:when test="${not empty cart.imgPath}">
                                            <img src="<c:url value='${cart.imgPath}'/>" alt="<c:out value='${cart.prdNm}'/>"
                                                 style="max-height:70px; max-width:70px;"
                                                 onerror="this.parentElement.innerHTML='No Image'">
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-muted">No Image</small>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <a href="<c:url value='/dp/good/prdDtl.do?prdCd=${cart.prdCd}'/>" class="text-dark">
                                    <strong><c:out value="${cart.prdNm}"/></strong>
                                </a>
                                <c:if test="${not empty cart.smplDesc}">
                                    <br><small class="text-muted"><c:out value="${cart.smplDesc}"/></small>
                                </c:if>
                                <c:if test="${cart.prdStatCd == '40'}">
                                    <br><span class="badge badge-danger">일시품절</span>
                                </c:if>
                            </td>
                            <td class="text-center align-middle">
                                <fmt:formatNumber value="${cart.salePrc}" pattern="#,###"/>원
                            </td>
                            <td class="text-center align-middle">
                                <div class="input-group input-group-sm">
                                    <div class="input-group-prepend">
                                        <button class="btn btn-outline-secondary" type="button" onclick="changeQty(this, -1)">-</button>
                                    </div>
                                    <input type="number" class="form-control text-center cart-qty"
                                           value="${cart.ordQty}" min="1"
                                           <c:if test="${cart.stockQty > 0}">max="${cart.stockQty}"</c:if>
                                           data-cart-no="${cart.cartNo}" style="max-width:60px;"
                                           onchange="updateQty(this)">
                                    <div class="input-group-append">
                                        <button class="btn btn-outline-secondary" type="button" onclick="changeQty(this, 1)">+</button>
                                    </div>
                                </div>
                            </td>
                            <td class="text-center align-middle font-weight-bold cart-subtotal">
                                <fmt:formatNumber value="${cart.salePrc * cart.ordQty}" pattern="#,###"/>원
                            </td>
                            <td class="text-center align-middle">
                                <button type="button" class="btn btn-sm btn-outline-danger"
                                        onclick="deleteCart(${cart.cartNo})">X</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- 합계 영역 -->
            <div class="card mt-3">
                <div class="card-body text-center">
                    <div class="row align-items-center">
                        <div class="col">
                            <small class="text-muted">상품금액</small><br>
                            <strong id="totalPrdAmt">0</strong>원
                        </div>
                        <div class="col-auto"><h4>+</h4></div>
                        <div class="col">
                            <small class="text-muted">배송비</small><br>
                            <strong>0</strong>원
                        </div>
                        <div class="col-auto"><h4>=</h4></div>
                        <div class="col">
                            <small class="text-muted">총 결제금액</small><br>
                            <strong class="text-primary h5" id="totalPayAmt">0</strong>원
                        </div>
                    </div>
                </div>
            </div>

            <!-- 주문 버튼 -->
            <div class="text-center mt-4 mb-4">
                <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-secondary btn-lg mr-2">쇼핑 계속하기</a>
                <button type="button" class="btn btn-primary btn-lg" onclick="goOrder()">주문하기</button>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5">
                <p class="text-muted mb-4">장바구니가 비어있습니다.</p>
                <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-primary">상품 보러가기</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
$(document).ready(function() {
    calcTotal();
});

/* 전체선택 (품절 등 disabled 항목은 제외) */
function checkAllCart(el) {
    $('.cart-chk:not(:disabled)').prop('checked', $(el).is(':checked'));
    calcTotal();
}

/* 선택된 상품만 합계에 반영 */
function calcTotal() {
    var total = 0;
    $('tbody tr').each(function() {
        var prc = parseInt($(this).data('sale-prc')) || 0;
        var qty = parseInt($(this).find('.cart-qty').val()) || 0;
        var subtotal = prc * qty;
        $(this).find('.cart-subtotal').text(numberFormat(subtotal) + '원');
        if ($(this).find('.cart-chk').is(':checked')) {
            total += subtotal;
        }
    });
    $('#totalPrdAmt').text(numberFormat(total));
    $('#totalPayAmt').text(numberFormat(total));
}

function numberFormat(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function changeQty(btn, delta) {
    var input = $(btn).closest('.input-group').find('.cart-qty');
    var val = parseInt(input.val()) + delta;
    var max = parseInt(input.attr('max'));
    if (val < 1) val = 1;
    /* max 미설정 = 재고 미관리 상품이므로 상한 없음 */
    if (max && val > max) val = max;
    input.val(val);
    updateQty(input[0]);
}

function updateQty(el) {
    var cartNo = $(el).data('cart-no');
    var ordQty = $(el).val();

    $.ajax({
        url: '<c:url value="/od/cart/updateCart.do"/>',
        type: 'POST',
        data: { cartNo: cartNo, ordQty: ordQty },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS') {
                calcTotal();
            } else {
                alert(data.rtnMsg || '오류가 발생했습니다.');
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}

function deleteCart(cartNo) {
    if (!confirm('삭제하시겠습니까?')) return;

    $.ajax({
        url: '<c:url value="/od/cart/deleteCart.do"/>',
        type: 'POST',
        data: { cartNo: cartNo },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS') {
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

function goOrder() {
    // 선택된 장바구니 상품만 주문페이지로 전달
    var cartNos = [];
    $('.cart-chk:checked').each(function() {
        cartNos.push($(this).val());
    });

    if (cartNos.length === 0) {
        alert('주문할 상품을 선택해주세요.');
        return;
    }

    location.href = '<c:url value="/od/order/orderInit.do"/>?fromCart=Y&cartNoList=' + cartNos.join(',');
}
</script>
