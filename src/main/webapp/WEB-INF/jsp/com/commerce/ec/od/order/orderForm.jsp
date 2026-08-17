<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container mt-4">
    <h4 class="mb-4">주문서</h4>

    <c:choose>
        <c:when test="${not empty orderPrdList}">
            <!-- 주문 상품 목록 -->
            <div class="card mb-4">
                <div class="card-header"><strong>주문 상품</strong></div>
                <div class="card-body p-0">
                    <table class="table table-borderless mb-0">
                        <c:forEach var="prd" items="${orderPrdList}" varStatus="status">
                            <tr data-prd-cd="${prd.prdCd}" data-sale-prc="${prd.salePrc}"
                            data-card-disc-prc="${prd.cardDiscPrc}" data-cash-disc-prc="${prd.cashDiscPrc}"
                            data-ord-qty="${prd.ordQty}">
                                <td style="width:80px">
                                    <div class="bg-light text-center" style="width:70px; height:70px; line-height:70px;">
                                        <c:choose>
                                            <c:when test="${not empty prd.imgPath}">
                                                <img src="<c:url value='${prd.imgPath}'/>" alt="<c:out value='${prd.prdNm}'/>"
                                                     style="max-height:70px; max-width:70px;"
                                                     onerror="this.parentElement.innerHTML='No Image'">
                                            </c:when>
                                            <c:otherwise><small class="text-muted">No Image</small></c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <td>
                                    <strong><c:out value="${prd.prdNm}"/></strong>
                                    <c:if test="${not empty prd.smplDesc}">
                                        <br><small class="text-muted"><c:out value="${prd.smplDesc}"/></small>
                                    </c:if>
                                </td>
                                <td class="text-right align-middle" style="width:120px">
                                    <fmt:formatNumber value="${prd.salePrc}" pattern="#,###"/>원
                                    <br><small class="text-muted">${prd.ordQty}개</small>
                                </td>
                                <td class="text-right align-middle font-weight-bold" style="width:120px">
                                    <fmt:formatNumber value="${prd.salePrc * prd.ordQty}" pattern="#,###"/>원
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                </div>
            </div>

            <!-- 배송 정보 -->
            <div class="card mb-4">
                <div class="card-header"><strong>배송 정보</strong></div>
                <div class="card-body">
                    <form id="orderForm">
                        <%-- 주문번호는 결제하기를 누를 때 서버가 만든다.
                             카드결제는 그 번호로 임시 주문을 먼저 저장한 뒤 결제로 넘어간다. --%>
                        <input type="hidden" name="ordNo" value="">
                        <input type="hidden" name="fromCart" value="${fromCart}">
                        <input type="hidden" name="cartNoList" value="<c:out value='${cartNoList}'/>">
                        <c:if test="${empty fromCart}">
                            <input type="hidden" name="prdCd" value="${orderPrdList[0].prdCd}">
                            <input type="hidden" name="ordQty" value="${orderPrdList[0].ordQty}">
                        </c:if>

                        <div class="form-group row">
                            <label class="col-sm-2 col-form-label">받는분 <span class="text-danger">*</span></label>
                            <div class="col-sm-4">
                                <input type="text" name="reciverNm" class="form-control"
                                       value="<c:out value='${mbrInfo.mbrNm}'/>" required>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-2 col-form-label">연락처 <span class="text-danger">*</span></label>
                            <div class="col-sm-4">
                                <input type="text" name="delvHpNo" class="form-control"
                                       value="<c:out value='${mbrInfo.hpNo}'/>" placeholder="010-0000-0000" required>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-2 col-form-label">우편번호</label>
                            <div class="col-sm-3">
                                <input type="text" name="delvZipcode" class="form-control"
                                       value="<c:out value='${mbrInfo.zipcode}'/>" placeholder="우편번호">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-2 col-form-label">주소 <span class="text-danger">*</span></label>
                            <div class="col-sm-6">
                                <input type="text" name="delvBaseAddr" class="form-control mb-2"
                                       value="<c:out value='${mbrInfo.baseAddr}'/>" placeholder="기본주소" required>
                                <input type="text" name="delvDtlAddr" class="form-control"
                                       value="<c:out value='${mbrInfo.dtlAddr}'/>" placeholder="상세주소">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-2 col-form-label">배송메모</label>
                            <div class="col-sm-6">
                                <select name="delvMsg" class="form-control">
                                    <option value="">선택해주세요</option>
                                    <option value="부재시 경비실에 맡겨주세요">부재시 경비실에 맡겨주세요</option>
                                    <option value="부재시 문 앞에 놓아주세요">부재시 문 앞에 놓아주세요</option>
                                    <option value="배송 전 연락 바랍니다">배송 전 연락 바랍니다</option>
                                    <option value="직접 수령하겠습니다">직접 수령하겠습니다</option>
                                </select>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- 결제 수단 -->
            <div class="card mb-4">
                <div class="card-header"><strong>결제 수단</strong></div>
                <div class="card-body">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="payTpCd" id="pay10" value="10" checked>
                        <label class="form-check-label" for="pay10">무통장입금</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="payTpCd" id="pay20" value="20">
                        <label class="form-check-label" for="pay20">카드결제</label>
                    </div>

                    <!-- 무통장입금 선택 시에만 노출 -->
                    <div id="depositArea" class="mt-3">
                        <div class="form-group row mb-0">
                            <label class="col-sm-2 col-form-label">입금자명 <span class="text-danger">*</span></label>
                            <div class="col-sm-4">
                                <input type="text" name="depositorNm" id="depositorNm" class="form-control"
                                       value="<c:out value='${mbrInfo.mbrNm}'/>" maxlength="50">
                            </div>
                            <div class="col-sm-6">
                                <small class="text-muted">
                                    주문 완료 후 안내되는 계좌로 입금해주세요.<br>
                                    입금자명이 다르면 입금 확인이 지연될 수 있습니다.
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 결제 금액 -->
            <div class="card mb-4">
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
                            <strong class="text-primary h4" id="totalPayAmt">0</strong>원
                        </div>
                    </div>
                </div>
            </div>

            <!-- 주문 버튼 -->
            <div class="text-center mb-4">
                <button type="button" class="btn btn-outline-secondary btn-lg mr-2" onclick="history.back()">이전으로</button>
                <button type="button" class="btn btn-primary btn-lg" id="btnOrder" onclick="doOrder()">결제하기</button>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-5">
                <p class="text-muted">주문 가능한 상품이 없습니다.</p>
                <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-primary">상품 보러가기</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
$(document).ready(function() {
    calcTotal();
    toggleDepositArea();
    $('input[name=payTpCd]').on('change', function() {
        calcTotal();
        toggleDepositArea();
    });
});

/* 무통장입금(10) 선택 시에만 입금자명 입력란 노출 */
function toggleDepositArea() {
    if ($('input[name=payTpCd]:checked').val() === '10') {
        $('#depositArea').show();
    } else {
        $('#depositArea').hide();
    }
}

function calcTotal() {
    var payTpCd = $('input[name=payTpCd]:checked').val();
    var total = 0;
    $('tr[data-prd-cd]').each(function() {
        var salePrc = parseInt($(this).data('sale-prc')) || 0;
        var cardDiscPrc = parseInt($(this).data('card-disc-prc')) || 0;
        var cashDiscPrc = parseInt($(this).data('cash-disc-prc')) || 0;
        var qty = parseInt($(this).data('ord-qty')) || 0;

        var prc = salePrc;
        if (payTpCd === '20' && cardDiscPrc > 0) prc = cardDiscPrc;
        else if (payTpCd === '10' && cashDiscPrc > 0) prc = cashDiscPrc;

        total += prc * qty;
    });
    $('#totalPrdAmt').text(numberFormat(total));
    $('#totalPayAmt').text(numberFormat(total));
}

function numberFormat(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/* 결제를 시작하면 로딩 레이어로 화면을 덮고, 응답이 오면 걷는다.
   덮여 있는 동안에는 결제 버튼이 눌리지 않으므로 이 레이어가 중복 결제를 막는다.
   ※ 서버에는 같은 주문이 두 번 들어오는 것을 막는 장치가 없다.
      방어가 화면에만 있어서, 요청을 직접 보내면 걸릴 것이 없다. */
function setOrderProcessing(on) {
    if (on) {
        comm_loading.loadingShow('결제를 진행하고 있습니다.<br>잠시만 기다려주세요.');
    } else {
        comm_loading.loadingHide();
    }
}

function doOrder() {
    var form = $('#orderForm');
    var reciverNm = form.find('[name=reciverNm]').val();
    var delvHpNo = form.find('[name=delvHpNo]').val();
    var delvBaseAddr = form.find('[name=delvBaseAddr]').val();

    var payTpCd = $('input[name=payTpCd]:checked').val();
    var depositorNm = $.trim($('#depositorNm').val());

    if (!reciverNm) { alert('받는분을 입력해주세요.'); return; }
    if (!delvHpNo) { alert('연락처를 입력해주세요.'); return; }
    if (!delvBaseAddr) { alert('주소를 입력해주세요.'); return; }
    if (payTpCd === '10' && !depositorNm) {
        alert('입금자명을 입력해주세요.');
        $('#depositorNm').focus();
        return;
    }

    if (!confirm('주문하시겠습니까?')) return;

    /* 폼 값 + 결제수단. ordNo 는 hidden 에 들어 있으므로 serialize 에 따라온다. */
    function buildData() {
        var d = form.serialize() + '&payTpCd=' + payTpCd;
        if (payTpCd === '10') {
            d += '&depositorNm=' + encodeURIComponent(depositorNm);
        }
        return d;
    }

    setOrderProcessing(true);

    if (payTpCd === '20') {
        /* 카드결제는 결제 준비를 먼저 한다.
           주문번호를 받아 임시 주문에 담아두고, 그 번호로 결제를 확정한다.
           결제창을 거치는 동안 주문 내용을 서버에 남겨두기 위한 단계다. */
        $.ajax({
            url: '<c:url value="/od/order/prepareOrder.do"/>',
            type: 'POST',
            data: buildData(),
            dataType: 'json',
            success: function(result) {
                if (result.rtnCode !== 'SUCCESS') {
                    alert(result.rtnMsg || '오류가 발생했습니다.');
                    setOrderProcessing(false);
                    return;
                }
                form.find('[name=ordNo]').val(result.ordNo);
                submitOrder(buildData());
            },
            error: function() {
                alert('시스템 오류가 발생했습니다.');
                setOrderProcessing(false);
            }
        });
    } else {
        /* 무통장입금은 결제창을 거치지 않는다. 이탈 구간이 없으므로 임시 주문 없이 바로 확정한다. */
        submitOrder(buildData());
    }
}

function submitOrder(data) {
    $.ajax({
        url: '<c:url value="/od/order/saveOrder.do"/>',
        type: 'POST',
        data: data,
        dataType: 'json',
        success: function(result) {
            if (result.rtnCode === 'SUCCESS') {
                /* 주문완료 화면으로 이동하므로 버튼을 되돌리지 않는다 */
                location.href = '<c:url value="/od/order/orderSuccess.do"/>?ordNo=' + result.ordNo;
            } else if (result.rtnCode === 'LOGIN_REQUIRED') {
                alert('로그인이 필요합니다.');
                location.href = '<c:url value="/login.do"/>';
            } else {
                alert(result.rtnMsg || '오류가 발생했습니다.');
                setOrderProcessing(false);
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
            setOrderProcessing(false);
        }
    });
}
</script>
