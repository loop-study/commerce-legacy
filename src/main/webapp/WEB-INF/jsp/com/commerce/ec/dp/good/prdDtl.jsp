<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mt-4">
    <c:if test="${not empty prdInfo}">
        <!-- 브레드크럼 -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<c:url value='/main.do'/>">홈</a></li>
                <li class="breadcrumb-item"><a href="<c:url value='/dp/good/prdList.do?lCatCd=${prdInfo.LCatCd}'/>"><c:out value="${prdInfo.LCatNm}"/></a></li>
                <c:if test="${not empty prdInfo.MCatNm}">
                    <li class="breadcrumb-item"><c:out value="${prdInfo.MCatNm}"/></li>
                </c:if>
                <c:if test="${not empty prdInfo.SCatNm}">
                    <li class="breadcrumb-item active"><c:out value="${prdInfo.SCatNm}"/></li>
                </c:if>
            </ol>
        </nav>

        <div class="row">
            <!-- 상품 이미지 -->
            <div class="col-md-6">
                <div class="bg-light text-center p-4" style="min-height:400px; line-height:380px;">
                    <c:choose>
                        <c:when test="${not empty imgList and not empty imgList[0].imgPath}">
                            <img src="<c:url value='${imgList[0].imgPath}'/>" alt="<c:out value='${prdInfo.prdNm}'/>"
                                 style="max-height:400px; max-width:100%;"
                                 onerror="this.parentElement.innerHTML='No Image'">
                        </c:when>
                        <c:otherwise>
                            <span class="text-muted" style="font-size:1.5rem;">No Image</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <!-- 상세이미지 썸네일 (IMG_TP_CD 20) -->
                <c:if test="${not empty imgList}">
                    <div class="d-flex mt-2">
                        <c:forEach var="img" items="${imgList}" varStatus="status">
                            <c:if test="${img.imgTpCd == '20'}">
                                <div class="mr-2 bg-light text-center" style="width:80px; height:80px; line-height:80px;">
                                    <img src="<c:url value='${img.imgPath}'/>" alt="상세이미지${status.index}"
                                         style="max-height:80px; max-width:100%;"
                                         onerror="this.style.display='none'">
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <!-- 상품 정보 -->
            <div class="col-md-6">
                <!-- 상품 상태 뱃지 -->
                <c:if test="${prdInfo.prdStatCd == '40'}">
                    <span class="badge badge-danger mb-2">일시품절</span>
                </c:if>
                <c:if test="${prdInfo.prdStatCd == '50'}">
                    <span class="badge badge-warning mb-2">예약판매</span>
                </c:if>

                <h3><c:out value="${prdInfo.prdNm}"/></h3>
                <p class="text-muted"><c:out value="${prdInfo.smplDesc}"/></p>

                <hr>

                <!-- 가격 정보 -->
                <table class="table table-borderless">
                    <tr>
                        <th class="w-25 text-muted">판매가</th>
                        <td class="font-weight-bold h5">
                            <fmt:formatNumber value="${prdInfo.salePrc}" pattern="#,###"/>원
                        </td>
                    </tr>
                    <c:if test="${prdInfo.cardDiscPrc > 0 and prdInfo.cardDiscPrc < prdInfo.salePrc}">
                        <tr>
                            <th class="text-muted">카드할인</th>
                            <td class="text-danger">
                                <fmt:formatNumber value="${prdInfo.cardDiscPrc}" pattern="#,###"/>원
                            </td>
                        </tr>
                    </c:if>
                    <c:if test="${prdInfo.cashDiscPrc > 0 and prdInfo.cashDiscPrc < prdInfo.salePrc}">
                        <tr>
                            <th class="text-muted">현금할인</th>
                            <td class="text-primary">
                                <fmt:formatNumber value="${prdInfo.cashDiscPrc}" pattern="#,###"/>원
                            </td>
                        </tr>
                    </c:if>
                    <tr>
                        <th class="text-muted">배송</th>
                        <td>
                            <c:choose>
                                <c:when test="${prdInfo.delvTpCd == '10'}">자체배송 (무료)</c:when>
                                <c:when test="${prdInfo.delvTpCd == '20'}">업체배송</c:when>
                            </c:choose>
                        </td>
                    </tr>
                    <%-- 재고수량 0 = 재고 미관리(수량제한 없음) 이므로 미노출 --%>
                    <c:if test="${prdInfo.stockQty > 0}">
                        <tr>
                            <th class="text-muted">재고</th>
                            <td>${prdInfo.stockQty}개</td>
                        </tr>
                    </c:if>
                </table>

                <hr>

                <!-- 수량 선택 + 장바구니 -->
                <form id="cartForm">
                    <input type="hidden" name="prdCd" value="${prdInfo.prdCd}">
                    <div class="form-group row">
                        <label class="col-sm-3 col-form-label text-muted">수량</label>
                        <div class="col-sm-4">
                            <input type="number" name="ordQty" class="form-control" value="1" min="1"
                                   <c:if test="${prdInfo.stockQty > 0}">max="${prdInfo.stockQty}"</c:if> id="ordQty">
                        </div>
                    </div>
                    <div class="mt-3">
                        <c:choose>
                            <c:when test="${prdInfo.prdStatCd == '30'}">
                                <button type="button" class="btn btn-primary btn-lg mr-2" onclick="addToCart()">장바구니</button>
                                <button type="button" class="btn btn-success btn-lg" onclick="orderNow()">바로구매</button>
                            </c:when>
                            <c:when test="${prdInfo.prdStatCd == '40'}">
                                <button type="button" class="btn btn-secondary btn-lg" disabled>일시품절</button>
                            </c:when>
                            <c:when test="${prdInfo.prdStatCd == '50'}">
                                <button type="button" class="btn btn-warning btn-lg mr-2" onclick="addToCart()">예약 장바구니</button>
                            </c:when>
                        </c:choose>
                    </div>
                </form>
            </div>
        </div>

        <!-- 상품 상세정보 (상세이미지 IMG_TP_CD 20) -->
        <c:set var="dtlImgCnt" value="0"/>
        <c:forEach var="img" items="${imgList}">
            <c:if test="${img.imgTpCd == '20'}"><c:set var="dtlImgCnt" value="${dtlImgCnt + 1}"/></c:if>
        </c:forEach>
        <c:if test="${dtlImgCnt > 0}">
            <hr class="mt-5">
            <h5 class="mb-3">상품 상세정보</h5>
            <div class="text-center mb-5">
                <c:forEach var="img" items="${imgList}">
                    <c:if test="${img.imgTpCd == '20'}">
                        <img src="<c:url value='${img.imgPath}'/>" alt="<c:out value='${prdInfo.prdNm}'/> 상세이미지"
                             class="img-fluid d-block mx-auto mb-2" style="max-width:800px;"
                             onerror="this.style.display='none'">
                    </c:if>
                </c:forEach>
            </div>
        </c:if>
    </c:if>

    <c:if test="${empty prdInfo}">
        <div class="text-center py-5">
            <p class="text-muted">상품 정보를 찾을 수 없습니다.</p>
            <a href="<c:url value='/dp/good/prdList.do'/>" class="btn btn-outline-primary">상품 목록으로</a>
        </div>
    </c:if>
</div>

<script>
function addToCart() {
    var prdCd = $('input[name=prdCd]').val();
    var ordQty = $('#ordQty').val();

    $.ajax({
        url: '<c:url value="/od/cart/addCart.do"/>',
        type: 'POST',
        data: { prdCd: prdCd, ordQty: ordQty },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS') {
                if (confirm('장바구니에 담았습니다. 장바구니로 이동하시겠습니까?')) {
                    location.href = '<c:url value="/od/cart/cartInit.do"/>';
                }
            } else if (data.rtnCode === 'LOGIN_REQUIRED') {
                alert('로그인이 필요합니다.');
                location.href = '<c:url value="/login.do"/>';
            } else {
                alert(data.rtnMsg || '오류가 발생했습니다.');
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}

function orderNow() {
    var prdCd = $('input[name=prdCd]').val();
    var ordQty = $('#ordQty').val();
    location.href = '<c:url value="/od/order/orderInit.do"/>?prdCd=' + prdCd + '&ordQty=' + ordQty;
}
</script>