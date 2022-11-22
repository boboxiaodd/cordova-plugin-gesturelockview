const exec = require('cordova/exec');
const CDVLocalGestureLockView = {
    show :function (success,options){
        exec(success, null, 'CDVGestureLockView','show',[options]);
    },
    hide : function (){
        exec(null, null, 'CDVGestureLockView','hide',[]);
    },
};
module.exports = CDVLocalGestureLockView;
