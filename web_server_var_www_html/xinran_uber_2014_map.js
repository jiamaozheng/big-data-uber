var map;
var dayOfWeekDisplay = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
var listOfPoints = [];

function initMap() {
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 12,
        center: {
            lat: 40.761104,
            lng: -73.949988
        },
        mapTypeId: 'satellite'
    });
}

function getColor(value) {
    // http://stackoverflow.com/questions/7128675/from-green-to-red-color-depend-on-percentage
    if (value > 1) {
        value = 1;
    }
    if (value < 0) {
        value = 0;
    }
    // value from 0 to 1
    var hue = ((1 - value) * 120).toString(10);
    return ["hsl(", hue, ",100%,50%)"].join("");
}

function drawOnMap(strs) {
    // remove existing circles from map, if any
    if (listOfPoints.length > 0) {
        for (var x in listOfPoints) {
            listOfPoints[x].setMap(null);
            listOfPoints[x] = null;
        }
        listOfPoints.length = 0;
    }
    // draw new circles on map
    for (var i = 3; i < strs.length; i += 3) {
        var myLat = parseFloat(strs[i]);
        var myLon = parseFloat(strs[i + 1]);
        var myCount = parseInt(strs[i + 2]);
        var myCircle = new google.maps.Circle({
            strokeWeight: 0,
            fillColor: getColor(myCount / 15),
            fillOpacity: 0.7,
            map: map,
            center: {
                lat: myLat,
                lng: myLon
            },
            radius: 42
        });
        listOfPoints.push(myCircle);
    }
}

$(function() {
    var slider = $("#floating-slider").slider({
        min: 1,
        max: 183,
        range: "min",
        value: 1,
        slide: function(event, ui) {
            $("#floating-display").text("Day " + ui.value);
        },
        stop: function(event, ui) {
            $.get("/cgi-bin/xinran/xinran_uber_2014_map.pl", {
                "daySince20140401": ui.value
            }, function(data, status) {
                var strs = data.split(",");
                $("#floating-display").text("Uber Pickup " + strs[1] + " " + dayOfWeekDisplay[strs[2]] + " (Day " + strs[0] + ")");
                drawOnMap(strs);
            })
        }
    });
});


