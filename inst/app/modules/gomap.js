// Zoom to the specified location on a leaflet map in shiny
// adapted from https://github.com/rstudio/shiny-examples/blob/main/063-superzip-example/gomap.js

// When locator icon in datatable is clicked, go to that spot on the map
$(document).on("click", ".go-map", function(e) {
  e.preventDefault();
  $el = $(this);
  var lat = $el.data("lat");
  var lng = $el.data("lng");
  // $($("#nav a")[0]).tab("show");
  Shiny.onInputChange("goto", {
    lat: lat,
    lng: lng,
    nonce: Math.random()
  });
});
