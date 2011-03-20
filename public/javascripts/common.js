  function update_total_count(){
    (registration_total_bro).value = parseInt((registration_bk_bro).value) + parseInt((registration_nbk_bro).value);
    (registration_total_sis).value = parseInt((registration_bk_sis).value) + parseInt((registration_nbk_sis).value);
    (registration_total_teachers).value = parseInt((registration_bk_teachers).value) ;
    (registration_grand_total).value = parseInt((registration_total_teachers).value) + parseInt((registration_total_bro).value) + parseInt((registration_total_sis).value) ;
  }
function update_count(obj, registration_count){
  if(obj.checked) {(registration_count).value = parseInt((registration_count).value) + 1 } 
  else {(registration_count).value = parseInt((registration_count).value) - 1}; 
  update_total_count();
  }

