window.externalApp = {};
window.externalApp.getExternalAuth = function(options) {
    console.log("Starting external auth");
    var options = JSON.parse(options);
    if (options && options.callback) {
        var responseData = {
            access_token: "[token]",
            expires_in: 1800
        };
        console.log("Waiting for callback to be added");
        setTimeout(function(){
            console.log("Calling a callback");
            window[options.callback](true, responseData);
        }, 500);
    }
};
/*
window.externalApp.externalBus = function(message) {
    console.log("External bus message: " + message);
    var messageObj = JSON.parse(message);
    if (messageObj.type == "config/get") {
        var responseData = {
            id: messageObj.id,
            type: "result",
            success: true,
            result: {
                hasSettingsScreen: true
            }
        };
        setTimeout(function(){
            window.externalBus(responseData);
        }, 500);
    } else if (messageObj.type == "config_screen/show") {
        HAClient.postMessage('show-settings');
    }
};
*/