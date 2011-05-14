// Create New participant related JS APIs
function show_hide_surrender(obj) {
  if (obj.value=="Teacher"){$("#surrender").show();} 
  else {$("#surrender").hide();}
}

$(document).ready(function(){

// More Info show/hide functionality
    $("#see_hide_more_info").click(function(){$('div[id="more_info"]').slideToggle("slow");});
    })
