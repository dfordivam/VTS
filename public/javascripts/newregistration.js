// New Registration page only javascript APIs 
function update_total_count(){
    $("#registration_total_bro").val(parseInt($("#registration_bk_bro").val()) + parseInt($("#registration_nbk_bro").val()));
    $("#registration_total_sis").val(parseInt($("#registration_bk_sis").val()) + parseInt($("#registration_nbk_sis").val()));
    $("#registration_total_teachers").val(parseInt($("#registration_bk_teachers").val()));
    $("#registration_grand_total").val(parseInt($("#registration_total_teachers").val()) +  parseInt($("#registration_total_sis").val()) + parseInt($("#registration_total_bro").val()));
  }
function update_count(obj, registration_count){
  if(obj.checked) {(registration_count).value = parseInt((registration_count).value) + 1 } 
  else {(registration_count).value = parseInt((registration_count).value) - 1}; 
  update_total_count();
  }


$(document).ready(function(){

// New registration page show/hide functionality
    $("#div_teacher").click(function(){$("#participant_category_div_teacher").slideToggle("slow");});
    $("#div_bk_bro").click(function(){$("#participant_category_div_bk_bro").slideToggle("slow");});
    $("#div_bk_sis").click(function(){$("#participant_category_div_bk_sis").slideToggle("slow");});
    $("#div_nbk_bro").click(function(){$("#participant_category_div_nbk_bro").slideToggle("slow");});
    $("#div_nbk_sis").click(function(){$("#participant_category_div_nbk_sis").slideToggle("slow");});
    $(".participant_list tr:last-child").click(function(){ $(this).parent().parent().parent().hide("slow"); });
    })
