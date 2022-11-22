const exec = require('cordova/exec');
const CDVLocalGestureLockView = {
    show :function (options){
        exec(null, null, 'CDVLocalGestureLockView','show',[options]);
    },
    hide : function (options){
        exec(null, null, 'CDVLocalGestureLockView','hide',[options]);
    },
};
module.exports = CDVLocalGestureLockView;
