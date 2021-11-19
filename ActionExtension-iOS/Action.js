var Action = function() {};

Action.prototype = {

run: function(parameters) {
    parameters.completionFunction({
        "URL": document.URL,
        "title": document.title,
        "selection": document.getSelection().toString()
    });
},

finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}

};

var ExtensionPreprocessingJS = new Action
