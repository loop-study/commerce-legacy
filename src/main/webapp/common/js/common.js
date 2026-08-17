/* ------------------------------------------------------------
 *  공통 로딩 레이어
 *
 *  결제처럼 응답이 언제 올지 모르는 요청 동안 화면을 덮어둔다.
 *  덮여 있는 사이에는 그 아래의 버튼과 링크가 눌리지 않으므로,
 *  결과적으로 이 레이어가 중복 클릭을 막는 역할까지 한다.
 *
 *    comm_loading.loadingShow();     // 요청 직전
 *    comm_loading.loadingHide();     // 응답을 받은 뒤
 * ------------------------------------------------------------ */
var comm_loading = {

    _build : function() {
        if (document.getElementById('commLoading')) {
            return;
        }
        var layer = document.createElement('div');
        layer.id = 'commLoading';
        layer.innerHTML =
              '<div class="comm-loading-box">'
            +     '<div class="comm-loading-spinner"></div>'
            +     '<p class="comm-loading-text"></p>'
            + '</div>';
        document.body.appendChild(layer);
    },

    loadingShow : function(msg) {
        this._build();
        var layer = document.getElementById('commLoading');
        layer.getElementsByClassName('comm-loading-text')[0].innerHTML =
            msg || '처리중입니다. 잠시만 기다려주세요.';
        layer.style.display = 'block';
    },

    loadingHide : function() {
        var layer = document.getElementById('commLoading');
        if (layer) {
            layer.style.display = 'none';
        }
    }
};
