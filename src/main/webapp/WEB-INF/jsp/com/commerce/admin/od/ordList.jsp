<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="mt-4">
    <h4>주문 관리</h4>

    <!-- 검색 -->
    <form action="<c:url value='/admin/od/ordList.do'/>" method="get" class="mb-4">
        <div class="row mb-2">
            <!-- 기간 -->
            <div class="col-auto">
                <div class="btn-group" role="group">
                    <a href="<c:url value='/admin/od/ordList.do?ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}&searchPeriod=1'/>"
                       class="btn btn-sm ${searchPeriod == '1' ? 'btn-secondary' : 'btn-outline-secondary'}">1개월</a>
                    <a href="<c:url value='/admin/od/ordList.do?ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}&searchPeriod=3'/>"
                       class="btn btn-sm ${searchPeriod == '3' ? 'btn-secondary' : 'btn-outline-secondary'}">3개월</a>
                    <a href="<c:url value='/admin/od/ordList.do?ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}&searchPeriod=6'/>"
                       class="btn btn-sm ${searchPeriod == '6' ? 'btn-secondary' : 'btn-outline-secondary'}">6개월</a>
                    <a href="<c:url value='/admin/od/ordList.do?ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}'/>"
                       class="btn btn-sm ${empty searchPeriod ? 'btn-secondary' : 'btn-outline-secondary'}">전체</a>
                </div>
            </div>
        </div>
        <div class="row">
            <!-- 주문 상태 -->
            <div class="col-md-2">
                <select name="ordStatCd" class="form-control form-control-sm">
                    <option value="">전체 상태</option>
                    <option value="10" <c:if test="${ordStatCd == '10'}">selected</c:if>>주문확인</option>
                    <option value="20" <c:if test="${ordStatCd == '20'}">selected</c:if>>결제완료</option>
                    <option value="30" <c:if test="${ordStatCd == '30'}">selected</c:if>>배송준비</option>
                    <option value="40" <c:if test="${ordStatCd == '40'}">selected</c:if>>배송중</option>
                    <option value="50" <c:if test="${ordStatCd == '50'}">selected</c:if>>배송완료</option>
                    <option value="90" <c:if test="${ordStatCd == '90'}">selected</c:if>>주문취소</option>
                </select>
            </div>
            <!-- 결제수단 -->
            <div class="col-md-2">
                <select name="payTpCd" class="form-control form-control-sm">
                    <option value="">전체 결제수단</option>
                    <option value="10" <c:if test="${payTpCd == '10'}">selected</c:if>>무통장입금</option>
                    <option value="20" <c:if test="${payTpCd == '20'}">selected</c:if>>카드결제</option>
                </select>
            </div>
            <!-- 회원 검색 -->
            <div class="col-md-4">
                <div class="input-group input-group-sm">
                    <input type="hidden" name="searchPeriod" value="<c:out value='${searchPeriod}'/>">
                    <input type="text" name="searchKeyword" class="form-control"
                           placeholder="회원명 / 아이디 검색" value="<c:out value='${searchKeyword}'/>">
                    <div class="input-group-append">
                        <button type="submit" class="btn btn-primary">검색</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <!-- 총 건수 -->
    <p class="text-muted">총 <strong>${totalCnt}</strong>건</p>

    <!-- 주문 목록 테이블 -->
    <table class="table table-bordered table-hover">
        <thead class="thead-light">
            <tr>
                <th>주문번호</th>
                <th>주문일시</th>
                <th>회원명</th>
                <th>아이디</th>
                <th>주문상품</th>
                <th>결제수단</th>
                <th>결제금액</th>
                <th>주문상태</th>
                <th>상세</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="ord" items="${ordList}">
                <tr>
                    <td><small><c:out value="${ord.ordNo}"/></small></td>
                    <td><small><c:out value="${ord.ordDt}"/></small></td>
                    <td><c:out value="${ord.mbrNm}"/></td>
                    <td><c:out value="${ord.loginId}"/></td>
                    <td>
                        <c:out value="${ord.firstPrdNm}"/>
                        <c:if test="${ord.dtlCnt > 1}">
                            <span class="text-muted"> 외 ${ord.dtlCnt - 1}건</span>
                        </c:if>
                    </td>
                    <td><c:out value="${ord.payTpNm}"/></td>
                    <td class="text-right">
                        <fmt:formatNumber value="${ord.payAmt}" pattern="#,###"/>원
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${ord.ordStatCd == '50'}">
                                <span class="badge badge-success"><c:out value="${ord.ordStatNm}"/></span>
                            </c:when>
                            <c:when test="${ord.ordStatCd == '90'}">
                                <span class="badge badge-danger"><c:out value="${ord.ordStatNm}"/></span>
                            </c:when>
                            <c:when test="${ord.ordStatCd == '40'}">
                                <span class="badge badge-warning"><c:out value="${ord.ordStatNm}"/></span>
                            </c:when>
                            <c:when test="${ord.ordStatCd == '10'}">
                                <span class="badge badge-info"><c:out value="${ord.ordStatNm}"/></span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-secondary"><c:out value="${ord.ordStatNm}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <button type="button" class="btn btn-sm btn-outline-primary"
                                onclick="openOrdDtl('<c:out value="${ord.ordNo}"/>')">상세</button>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty ordList}">
                <tr>
                    <td colspan="9" class="text-center py-4 text-muted">조회된 주문이 없습니다.</td>
                </tr>
            </c:if>
        </tbody>
    </table>

    <!-- 페이징 -->
    <c:if test="${totalCnt > 0}">
        <nav>
            <ul class="pagination justify-content-center">
                <c:if test="${startPage > 1}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/admin/od/ordList.do?pageNo=${prevPage}&searchPeriod=${searchPeriod}&ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}'/>">&laquo;</a>
                    </li>
                </c:if>
                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <li class="page-item <c:if test='${i == pageNo}'>active</c:if>">
                        <a class="page-link" href="<c:url value='/admin/od/ordList.do?pageNo=${i}&searchPeriod=${searchPeriod}&ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}'/>">${i}</a>
                    </li>
                </c:forEach>
                <c:if test="${endPage < totalPage}">
                    <li class="page-item">
                        <a class="page-link" href="<c:url value='/admin/od/ordList.do?pageNo=${nextPage}&searchPeriod=${searchPeriod}&ordStatCd=${ordStatCd}&payTpCd=${payTpCd}&searchKeyword=${searchKeyword}'/>">&raquo;</a>
                    </li>
                </c:if>
            </ul>
        </nav>
    </c:if>
</div>

<!-- 주문 상세 모달 -->
<div class="modal fade" id="ordDtlModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">주문 상세</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body" id="ordDtlBody">
                <div class="text-center py-3"><span class="text-muted">불러오는 중...</span></div>
            </div>
            <div class="modal-footer">
                <div class="mr-auto" id="ordStatChangeArea" style="display:none;">
                    <select id="ordStatSelect" class="form-control form-control-sm d-inline-block" style="width:auto;"></select>
                    <button type="button" class="btn btn-sm btn-primary" onclick="updateOrdStat()">상태변경</button>
                </div>
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>
var currOrdNo = null;

function openOrdDtl(ordNo) {
    currOrdNo = ordNo;
    $('#ordStatChangeArea').hide();
    $('#ordDtlBody').html('<div class="text-center py-3"><span class="text-muted">불러오는 중...</span></div>');
    $('#ordDtlModal').modal('show');

    $.ajax({
        url: '<c:url value="/admin/od/selectOrdDtl.do"/>',
        type: 'GET',
        data: { ordNo: ordNo },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode !== 'SUCCESS') {
                $('#ordDtlBody').html('<p class="text-danger text-center">상세 정보를 불러올 수 없습니다.</p>');
                return;
            }
            var d = data.ordDtl;
            var html = '';

            /* 주문 기본 정보 */
            html += '<h6 class="border-bottom pb-2 mb-3">주문 정보</h6>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">주문번호</div><div class="col-8">' + escHtml(d.ordNo) + '</div></div>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">주문일시</div><div class="col-8">' + escHtml(d.ordDt) + '</div></div>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">주문상태</div><div class="col-8">' + escHtml(d.ordStatNm) + '</div></div>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">결제수단</div><div class="col-8">' + escHtml(d.payTpNm) + '</div></div>';
            if (d.pgAprvNo) {
                html += '<div class="row mb-1"><div class="col-4 text-muted">승인번호</div><div class="col-8">' + escHtml(d.pgAprvNo) + '</div></div>';
            }
            if (d.payTpCd === '10') {
                html += '<div class="row mb-3"><div class="col-4 text-muted">입금자명</div><div class="col-8">' + (d.depositorNm ? escHtml(d.depositorNm) : '<span class="text-muted">-</span>') + '</div></div>';
            } else {
                html += '<div class="mb-3"></div>';
            }

            /* 회원 정보 */
            html += '<h6 class="border-bottom pb-2 mb-3">회원 정보</h6>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">회원명</div><div class="col-8">' + escHtml(d.mbrNm) + '</div></div>';
            html += '<div class="row mb-3"><div class="col-4 text-muted">아이디</div><div class="col-8">' + escHtml(d.loginId) + '</div></div>';

            /* 배송 정보 */
            html += '<h6 class="border-bottom pb-2 mb-3">배송 정보</h6>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">수령인</div><div class="col-8">' + escHtml(d.reciverNm) + '</div></div>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">연락처</div><div class="col-8">' + escHtml(d.delvHpNo) + '</div></div>';
            html += '<div class="row mb-1"><div class="col-4 text-muted">주소</div><div class="col-8">(' + escHtml(d.delvZipcode) + ') ' + escHtml(d.delvBaseAddr) + ' ' + escHtml(d.delvDtlAddr) + '</div></div>';
            html += '<div class="row mb-3"><div class="col-4 text-muted">배송메시지</div><div class="col-8">' + (d.delvMsg ? escHtml(d.delvMsg) : '<span class="text-muted">-</span>') + '</div></div>';

            /* 배송정보 (택배사/송장번호) */
            var d2 = data.delvInfo;
            html += '<h6 class="border-bottom pb-2 mb-3">배송정보</h6>';
            html += '<div class="form-group row">';
            html += '<label class="col-4 col-form-label text-muted">택배사</label>';
            html += '<div class="col-8"><select id="delvCoCd" class="form-control form-control-sm">';
            html += '<option value="">선택</option>';
            var coList = [['CJ','CJ대한통운'],['HANJIN','한진택배'],['LOTTE','롯데택배'],['POST','우체국택배'],['LOGEN','로젠택배']];
            for (var c = 0; c < coList.length; c++) {
                var sel = (d2 && d2.delvCoCd === coList[c][0]) ? ' selected' : '';
                html += '<option value="' + coList[c][0] + '"' + sel + '>' + coList[c][1] + '</option>';
            }
            html += '</select></div></div>';
            html += '<div class="form-group row">';
            html += '<label class="col-4 col-form-label text-muted">송장번호</label>';
            html += '<div class="col-8"><div class="input-group input-group-sm">';
            html += '<input type="text" id="invoiceNo" class="form-control" value="' + (d2 ? escHtml(d2.invoiceNo) : '') + '">';
            html += '<div class="input-group-append">';
            html += '<button type="button" class="btn btn-primary" onclick="saveOrdDelvInfo()">' + (d2 ? '수정' : '등록') + '</button>';
            html += '</div></div>';
            if (d2) {
                html += '<small class="text-muted">등록일시 ' + escHtml(d2.regDt) + '</small>';
            }
            html += '</div></div>';

            /* 주문 상품 */
            html += '<h6 class="border-bottom pb-2 mb-3">주문 상품</h6>';
            html += '<table class="table table-sm table-bordered">';
            html += '<thead class="thead-light"><tr><th>상품코드</th><th>상품명</th><th class="text-right">판매가</th><th class="text-right">할인</th><th class="text-right">수량</th><th class="text-right">소계</th></tr></thead>';
            html += '<tbody>';

            var list = data.ordDtlList;
            for (var i = 0; i < list.length; i++) {
                var p = list[i];
                html += '<tr>';
                html += '<td><small>' + escHtml(p.prdCd) + '</small></td>';
                html += '<td>' + escHtml(p.prdNm) + '</td>';
                html += '<td class="text-right">' + numFmt(p.salePrc) + '원</td>';
                html += '<td class="text-right">' + (p.discAmt > 0 ? '-' + numFmt(p.discAmt) + '원' : '-') + '</td>';
                html += '<td class="text-right">' + p.ordQty + '</td>';
                html += '<td class="text-right"><strong>' + numFmt(p.ordAmt) + '원</strong></td>';
                html += '</tr>';
            }
            html += '</tbody></table>';

            /* 결제 금액 */
            html += '<div class="text-right mt-2">';
            html += '<span class="text-muted mr-3">배송비 ' + numFmt(d.delvAmt) + '원</span>';
            html += '<strong class="h5">합계 ' + numFmt(d.payAmt) + '원</strong>';
            html += '</div>';

            $('#ordDtlBody').html(html);

            setOrdStatSelect(d.ordStatCd);
        },
        error: function() {
            $('#ordDtlBody').html('<p class="text-danger text-center">시스템 오류가 발생했습니다.</p>');
        }
    });
}

/* 현재 상태 기준으로 변경 가능한 상태만 select에 구성 (다음 단계 1개 + 취소) */
function setOrdStatSelect(currStatCd) {
    var names = { '20': '결제완료', '30': '배송준비', '40': '배송중', '50': '배송완료', '90': '주문취소' };
    var $select = $('#ordStatSelect').empty();

    /* 취소(90), 배송완료(50)는 변경 불가 */
    if (currStatCd === '90' || currStatCd === '50') {
        $('#ordStatChangeArea').hide();
        return;
    }

    var nextStatCd = String(parseInt(currStatCd, 10) + 10);
    if (names[nextStatCd]) {
        $select.append('<option value="' + nextStatCd + '">' + names[nextStatCd] + '</option>');
    }
    $select.append('<option value="90">주문취소</option>');
    $('#ordStatChangeArea').show();
}

function saveOrdDelvInfo() {
    var delvCoCd = $('#delvCoCd').val();
    var invoiceNo = $.trim($('#invoiceNo').val());

    if (!delvCoCd) {
        alert('택배사를 선택해주세요.');
        return;
    }
    if (!invoiceNo) {
        alert('송장번호를 입력해주세요.');
        $('#invoiceNo').focus();
        return;
    }

    $.ajax({
        url: '<c:url value="/admin/od/saveOrdDelvInfo.do"/>',
        type: 'POST',
        data: { ordNo: currOrdNo, delvCoCd: delvCoCd, invoiceNo: invoiceNo },
        dataType: 'json',
        success: function(data) {
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

function updateOrdStat() {
    var ordStatCd = $('#ordStatSelect').val();
    if (!ordStatCd) {
        return;
    }
    var statNm = $('#ordStatSelect option:selected').text();
    if (!confirm('주문 상태를 [' + statNm + '](으)로 변경하시겠습니까?')) {
        return;
    }
    $.ajax({
        url: '<c:url value="/admin/od/updateOrdStat.do"/>',
        type: 'POST',
        data: { ordNo: currOrdNo, ordStatCd: ordStatCd },
        dataType: 'json',
        success: function(data) {
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

function escHtml(str) {
    if (str == null) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function numFmt(num) {
    if (num == null) return '0';
    return Number(num).toLocaleString('ko-KR');
}
</script>
