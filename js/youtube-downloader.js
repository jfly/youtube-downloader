var ytdl = {};

(function() {

// Copied from http://www.nczonline.net/blog/2009/07/28/the-best-way-to-load-external-javascript/
function loadScript(url, callback){

    var script = document.createElement("script");
    script.type = "text/javascript";

    script.onload = function(){
      callback();
    };

    script.src = url;
    document.getElementsByTagName("head")[0].appendChild(script);
}

loadScript('js/swfobject.js', function() { });

var embededSwf = null;
ytdl.init = function(loadedSwfCallback) {
  if(embededSwf) {
    loadedSwfCallback(embededSwf);
    return;
  }

  window.HTTPGetLoadedCallback = function(success) {
    loadedSwfCallback(embededSwf);
  };
  function loadedCallback(e) {
    if(e.success) {
      embededSwf = e;
    } else {
      loadedSwfCallback(e);
    }
  }

  // This way if someone calls init again, we don't recreate the swf.
  embededSwf = { success: true, ref: 'loading' };

  var httpGetDiv = document.createElement('div');
  httpGetDiv.id = 'HTTPGet';
  document.body.appendChild(httpGetDiv);

  var flashVars = {};
  var params = {
    allowScriptAccess: 'always'
  };
  var width = "400";
  var height = "400";
  swfobject.embedSWF("swf/HTTPGet.swf", httpGetDiv.id, width, height, "9.0.0", null, flashVars, params, null, loadedCallback);
};


})();
