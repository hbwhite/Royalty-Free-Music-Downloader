function findAllURLs() {
    var urlsArray = "";
    
    var elements = document.all;
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];

        if (element.href) {
            urlsArray += element.href;
            urlsArray += ",";

        }
        else if (element.src) {
            urlsArray += element.src;
            urlsArray += ",";
        }
    }
    
    return urlsArray;
}