const exec = require('cordova/exec');
var channel = require('cordova/channel');
channel.createSticky('onCordovaWWWReady');
channel.waitForInitialization('onCordovaWWWWReady');
const CDVLocalWWW = {
    auth:"",
    is_debug:false,
    is_iphonex:true,
    showProgress :function (options){
        exec(null, null, 'CDVLocalWWW','showProgress',[options]);
    },
    setProgress : function (options){
        exec(null, null, 'CDVLocalWWW','setProgress',[options]);
    },
    hideProgress : function (){
        exec(null, null, 'CDVLocalWWW','hideProgress',[]);
    },
    goSetting : function (){
        exec(null, null, 'CDVLocalWWW','goSetting',[]);
    },
    goURL : function (success,options){
        exec(success, null, 'CDVLocalWWW','goURL',[options]);
    },
    playBeep: function (){
        exec(null, null, 'CDVLocalWWW','playBeep',[]);
    }
};
channel.onCordovaReady.subscribe(function () {
    exec(function(info) {
        CDVLocalWWW.is_debug   = info.is_debug;
        CDVLocalWWW.is_iphonex = info.is_iphonex;
        CDVLocalWWW.auth = info.auth;
        channel.onCordovaWWWWReady.fire();
    }, null, "CDVLocalWWW", "getSystemInfo", []);
});
module.exports = CDVLocalWWW;
