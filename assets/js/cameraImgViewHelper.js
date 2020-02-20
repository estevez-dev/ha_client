var messageChannel = 'HA_entity_id_placeholder';

function fixCameraImgView() {
    window.clearInterval(window.bodyDetectInterval);
    var img = document.getElementsByTagName('img');

    if (img && img.length) {
        img[0].setAttribute('width', document.body.clientWidth);
        img[0].removeAttribute('style');
        setTimeout(function() {
            window[messageChannel].postMessage(document.body.clientWidth / img[0].offsetHeight);
        }, 100);
    }
}

window.bodyDetectInterval = setInterval(function() {
    if (document.body != null && document.getElementsByTagName('img').length) {
        fixCameraImgView();
    }
}, 100);