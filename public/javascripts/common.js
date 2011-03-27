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

