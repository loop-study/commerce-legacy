<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="mt-4">
    <h4>
        <c:choose>
            <c:when test="${mode == 'edit'}">상품 수정</c:when>
            <c:otherwise>상품 등록</c:otherwise>
        </c:choose>
    </h4>

    <form id="prdForm" enctype="multipart/form-data">
        <input type="hidden" name="mode" value="${mode}">
        <c:if test="${mode == 'edit'}">
            <input type="hidden" name="prdCd" value="${prdInfo.prdCd}">
        </c:if>

        <div class="card mb-4">
            <div class="card-header">기본 정보</div>
            <div class="card-body">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">상품명 <span class="text-danger">*</span></label>
                    <div class="col-sm-10">
                        <input type="text" name="prdNm" class="form-control" value="<c:out value='${prdInfo.prdNm}'/>" required>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">요약정보</label>
                    <div class="col-sm-10">
                        <input type="text" name="smplDesc" class="form-control" value="<c:out value='${prdInfo.smplDesc}'/>">
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">대카테고리 <span class="text-danger">*</span></label>
                    <div class="col-sm-3">
                        <select name="lCatCd" class="form-control" id="lCatCd" onchange="loadSubCat(this.value, 'mCatCd')">
                            <option value="">선택</option>
                            <c:forEach var="cat" items="${lCatList}">
                                <option value="${cat.catCd}" <c:if test="${cat.catCd == prdInfo.LCatCd}">selected</c:if>><c:out value="${cat.catNm}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                    <label class="col-sm-1 col-form-label">중카테고리 <span class="text-danger">*</span></label>
                    <div class="col-sm-3">
                        <select name="mCatCd" class="form-control" id="mCatCd" onchange="loadSubCat(this.value, 'sCatCd')">
                            <option value="">선택</option>
                            <c:if test="${not empty mCatList}">
                                <c:forEach var="cat" items="${mCatList}">
                                    <option value="${cat.catCd}" <c:if test="${cat.catCd == prdInfo.MCatCd}">selected</c:if>><c:out value="${cat.catNm}"/></option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>
                    <label class="col-sm-1 col-form-label">소카테고리 <span class="text-danger">*</span></label>
                    <div class="col-sm-2">
                        <select name="sCatCd" class="form-control" id="sCatCd">
                            <option value="">선택</option>
                            <c:if test="${not empty sCatList}">
                                <c:forEach var="cat" items="${sCatList}">
                                    <option value="${cat.catCd}" <c:if test="${cat.catCd == prdInfo.SCatCd}">selected</c:if>><c:out value="${cat.catNm}"/></option>
                                </c:forEach>
                            </c:if>
                        </select>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">상품상태</label>
                    <div class="col-sm-3">
                        <select name="prdStatCd" class="form-control">
                            <option value="30" <c:if test="${prdInfo.prdStatCd == '30'}">selected</c:if>>판매중</option>
                            <option value="40" <c:if test="${prdInfo.prdStatCd == '40'}">selected</c:if>>일시품절</option>
                            <option value="50" <c:if test="${prdInfo.prdStatCd == '50'}">selected</c:if>>예약판매</option>
                            <option value="90" <c:if test="${prdInfo.prdStatCd == '90'}">selected</c:if>>판매종료</option>
                        </select>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">배송유형</label>
                    <div class="col-sm-3">
                        <select name="delvTpCd" class="form-control">
                            <option value="10" <c:if test="${prdInfo.delvTpCd == '10'}">selected</c:if>>자체배송</option>
                            <option value="20" <c:if test="${prdInfo.delvTpCd == '20'}">selected</c:if>>업체배송</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">가격/재고 정보</div>
            <div class="card-body">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">판매가 <span class="text-danger">*</span></label>
                    <div class="col-sm-3">
                        <input type="number" name="salePrc" class="form-control" value="${prdInfo.salePrc}" required>
                    </div>
                    <label class="col-sm-2 col-form-label">카드할인가(원)</label>
                    <div class="col-sm-2">
                        <input type="number" name="cardDiscPrc" class="form-control" value="${prdInfo.cardDiscPrc}" required>
                    </div>
                    <label class="col-sm-1 col-form-label">현금(원)</label>
                    <div class="col-sm-2">
                        <input type="number" name="cashDiscPrc" class="form-control" value="${prdInfo.cashDiscPrc}" required>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">재고수량</label>
                    <div class="col-sm-2">
                        <input type="number" name="stockQty" class="form-control"
                               value="${not empty prdInfo.stockQty ? prdInfo.stockQty : 9999}">
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header">이미지</div>
            <div class="card-body">
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">대표이미지</label>
                    <div class="col-sm-10">
                        <c:if test="${mode == 'edit' and not empty prdInfo.imgPath}">
                            <div class="mb-2">
                                <img src="<c:url value='${prdInfo.imgPath}'/>" alt="현재 이미지"
                                     style="max-height:120px; max-width:200px; border:1px solid #dee2e6;"
                                     onerror="this.style.display='none'">
                                <p class="mt-1 text-muted small">현재: <c:out value="${prdInfo.imgName}"/></p>
                            </div>
                        </c:if>
                        <input type="file" name="imgFile" class="form-control-file"
                               accept="image/jpeg,image/png,image/gif,image/webp">
                        <small class="form-text text-muted">
                            JPG, PNG, GIF, WEBP 형식 지원 (최대 15MB).
                            <c:if test="${mode == 'edit'}">새 파일을 선택하면 기존 이미지가 교체됩니다.</c:if>
                        </small>
                    </div>
                </div>
                <div class="form-group row">
                    <label class="col-sm-2 col-form-label">상세이미지</label>
                    <div class="col-sm-10">
                        <c:if test="${mode == 'edit' and not empty dtlImgList}">
                            <div class="mb-2">
                                <c:forEach var="dtlImg" items="${dtlImgList}">
                                    <img src="<c:url value='${dtlImg.imgPath}'/>" alt="상세이미지"
                                         style="max-height:80px; max-width:120px; border:1px solid #dee2e6;" class="mr-1"
                                         onerror="this.style.display='none'">
                                </c:forEach>
                                <p class="mt-1 text-muted small">현재 ${dtlImgList.size()}장 등록됨</p>
                            </div>
                        </c:if>
                        <input type="file" name="dtlImgFiles" class="form-control-file" multiple
                               accept="image/jpeg,image/png,image/gif,image/webp">
                        <small class="form-text text-muted">
                            여러 장 선택 가능. 선택한 순서대로 상품 상세화면에 노출됩니다.
                            <c:if test="${mode == 'edit'}">새로 선택하면 기존 상세이미지 전체가 교체됩니다.</c:if>
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <div class="text-center mb-5">
            <button type="button" class="btn btn-primary btn-lg" id="btnSavePrd" onclick="savePrd()">
                <c:choose>
                    <c:when test="${mode == 'edit'}">수정</c:when>
                    <c:otherwise>등록</c:otherwise>
                </c:choose>
            </button>
            <a href="<c:url value='/admin/gd/prdMng.do'/>" class="btn btn-secondary btn-lg">목록</a>
        </div>
    </form>
</div>

<script>
function loadSubCat(upCatCd, targetId) {
    var $target = $('#' + targetId);
    $target.html('<option value="">선택</option>');

    // 소카테고리도 초기화
    if (targetId === 'mCatCd') {
        $('#sCatCd').html('<option value="">선택</option>');
    }

    if (!upCatCd) return;

    $.ajax({
        url: '<c:url value="/admin/gd/selectSubCatList.do"/>',
        type: 'GET',
        data: { upCatCd: upCatCd },
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS' && data.catList) {
                $.each(data.catList, function(i, cat) {
                    $target.append('<option value="' + cat.catCd + '">' + cat.catNm + '</option>');
                });
            }
        }
    });
}

/* 저장 진행중 여부 - 중복 클릭 시 상품이 두 건 등록되는 것을 막는다 */
var prdSaving = false;

var prdSaveBtnText = null;

function setPrdSaving(on) {
    var btn = $('#btnSavePrd');
    if (prdSaveBtnText === null) {
        prdSaveBtnText = $.trim(btn.text());   // 등록/수정 모드에 따라 다름
    }
    prdSaving = on;
    btn.prop('disabled', on).text(on ? '저장 처리중...' : prdSaveBtnText);
}

function savePrd() {
    if (prdSaving) return;

    var prdNm = $('input[name=prdNm]').val();
    var salePrc = $('input[name=salePrc]').val();
    var cardDiscPrc = $('input[name=cardDiscPrc]').val();
    var cashDiscPrc = $('input[name=cashDiscPrc]').val();
    var lCatCd = $('#lCatCd').val();
    var mCatCd = $('#mCatCd').val();
    var sCatCd = $('#sCatCd').val();

    if (!prdNm) { alert('상품명을 입력해주세요.'); return; }
    if (!salePrc) { alert('판매가를 입력해주세요.'); return; }
    if (!cardDiscPrc) { alert('카드할인가를 입력해주세요.'); return; }
    if (!cashDiscPrc) { alert('현금할인가를 입력해주세요.'); return; }
    if (!lCatCd) { alert('대카테고리를 선택해주세요.'); return; }
    if (!mCatCd) { alert('중카테고리를 선택해주세요.'); return; }
    if (!sCatCd) { alert('소카테고리를 선택해주세요.'); return; }

    var formData = new FormData(document.getElementById('prdForm'));

    setPrdSaving(true);

    $.ajax({
        url: '<c:url value="/admin/gd/savePrd.do"/>',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: function(data) {
            if (data.rtnCode === 'SUCCESS') {
                alert(data.rtnMsg);
                location.href = '<c:url value="/admin/gd/prdMng.do"/>';
            } else {
                alert(data.rtnMsg || '오류가 발생했습니다.');
                setPrdSaving(false);
            }
        },
        error: function() {
            alert('시스템 오류가 발생했습니다.');
        }
    });
}
</script>
