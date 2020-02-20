function fixCameraImgView() {
    var img = document.getElementsByTagName('img');

    if (img && img.length) {
        img[0].setAttribute('width', document.body.clientWidth);
        img[0].setAttribute('style', 'margin-top: ' + ((document.body.clientHeight - img[0].offsetHeight) / 2));
    }
    var ovrl = document.getElementById('appOverlay');
    if (ovrl) {
        ovrl.remove();
    }
}

window.bodyDetectInterval = setInterval(function() {
    if (document.body != null) {
        setTimeout(fixCameraImgView, 1000);
    }
}, 100);