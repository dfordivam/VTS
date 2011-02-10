
$(document).ready(function(){

    setTimeout(function(){
        $("#errorExplanation, #notice").fadeOut(800);
    }, 25000);
    
    $("#arrival_date, .date").datepicker({
        minDate: 0,
        dateFormat: 'dd MM yy'
    });
    
    $(".birth").datepicker({
        changeMonth: true,
        changeYear: true,
        maxDate: '0',
        yearRange: '-100:+0',
        dateFormat: 'dd MM yy'
    });
    
    $("#adate, #ddate-1").datepicker({
        minDate: 0,
        dateFormat: 'dd MM yy',
        beforeShow: customRange
    });
    
    $("#event_start_date, #event_end_date").datepicker({
        minDate: 0,
        dateFormat: 'dd MM yy',
        beforeShow: customRange2
    });
    
    $(".numeric").livequery(function(){
        var id = $(this).attr('id');
        $(this).keyup(function(){
            var total = 0;
            var val = $(this).val();
            if (!IsNumeric(val)) {
                $(this).val(0);
            }
            checkTotal(id);
        });
        
        $(this).focus(function(){
            var val = trim($(this).val());
            if (val == 0) {
                $(this).val('');
            }
        });
        
        $(this).blur(function(){
            var val = trim($(this).val());
            if (val == '') {
                $(this).val('0');
            }
            checkTotal(id);
        });
    });
    
    $("#registrtionForm").submit(function(){
        var error = '';
        var t1 = parseInt($("#registration_grand_total").val());
        var t2 = 0;
        
        var fields = new Array('event', 'adate', 'transport', 'guide');
        for (i = 0; i < fields.length; i++) {
            var val = $("#" + fields[i]).val();
            if (fields[i] == 'event') {
                if (val == 0) {
                    error += '<li>Please select program name</li>';
                }
            }
            else 
                if (fields[i] == 'adate') {
                    if (val == '') {
                        error += '<li>Please select arrival date</li>';
                    }
                }
                else 
                    if (fields[i] == 'transport') {
                        if (val == 0) {
                            error += '<li>Please select arrival mode of travel</li>';
                        }
                    }
                    else 
                        if (fields[i] == 'guide') {
                            if (val == 0) {
                                error += '<li>Please enter guide name</li>';
                            }
                        }
        }
        
        $(".returns").each(function(){
            var temp = parseInt($(this).val());
            t2 += (isNaN(temp)) ? 0 : temp;
        });
        if (t2 != 0) {
            if (t1 < t2) {
                error += '<li><b>Number of people departing</b> are not correct</li>';
            }
        }
        else {
            error += '<li>Number of people departing missing</li>';
        }
        
        if (parseInt($("#valid_users_check").val()) && $("#students_list").length) {
            var t3 = parseInt($("input:checkbox:checked").length);
            if (t2 != t3) {
                error += '<li>Please check number of participants selected</li>';
            }
        }
        
        $(".returns").each(function(){
            var id = $(this).attr('id');
            var val = $(this).val();
            id = id.split('-');
            if (val != 0 || val != '') {
                if ($("#ddate-" + id[1]).val() == '') {
                    error += '<li>Please enter <b>Departure Date</b> in ' + id[1] + ' row</li>';
                }
                if ($("#depby-" + id[1]).val() == 0) {
                    error += '<li>Please select <b>Mode of Travel</b> in ' + id[1] + ' row</li>';
                }
            }
        });
        
        if (error == '') {
            $("#register").attr({
                disabled: 'disabled'
            }).val('Please wait ...');
            return true;
        }
        else {
            $("#errors").html(error);
            $('#error_message p.notify').remove();
            $("#error_message").prepend('<p class="notify">Please check below errors.</p>').fadeIn('slow');
            return false;
        }
    });
    
    $("#replyMsg").click(function(){
        var wd1 = $(document).width() / 2;
        var wd2 = $("#composeMsg").width() / 2;
        if (wd1 > wd2) {
            var wd = wd1 - wd2;
        }
        else {
            var wd = 0;
        }
        $("#composeMsg").css("left", wd);
        $("#overlay, #composeMsg").show();
    });
    
    $("#closeMsg").click(function(){
        $("#overlay, #composeMsg").hide();
    });
    
    $("#sendMsg").click(function(){
        $("#loader").show();
        
        var ed = tinyMCE.get('content');
        var msg = ed.getContent();
        
        var rid = $("#rid").val();
        
        var status = $('#composeMsg input[type=radio]:checked').val();
        
        $.ajax({
            type: "POST",
            url: "/registration/reply",
            data: {
                rid: rid,
                msg: msg,
                status: status
            },
            dataType: 'json',
            success: function(msg){
                $("#loader").hide();
                if (msg.status) {
                    sclass = "success";
                }
                else {
                    sclass = "error";
                }
                $("#replyStatus").html(msg.result).addClass(sclass).show();
                setTimeout(function(){
                    $("#overlay, #composeMsg").hide();
                    $("#replyStatus").html('').hide();
                }, 5000);
            }
        });
    });
    
    $("#printNotes").click(function(){
        var notes = $("#notes").html();
    });
    
    $(".event_check").livequery("click", function(){
        var id = $(this).attr('id');
        id = id.split('_');
        active = $(this).is(':checked')
        
        $.ajax({
            type: "POST",
            url: "/event/set_status",
            data: {
                id: id[1],
                active: active
            },
            dataType: 'json',
            success: function(msg){
            }
        });
    });
    
    $("#get_centre_list").change(function(){
        $("#list_loader").show();
        var id = $(this).val();
        
        $.ajax({
            type: "POST",
            url: "/participant/get_list",
            data: {
                centre_id: id
            },
            dataType: 'json',
            success: function(data){
                $("#list_loader").hide();
                if (data && data.length > 0) {
                    var list = "<ul id='students_list' class='list'>";
                    $.each(data, function(i, item){
                        list += "<li><input type='checkbox' value='" + item.participant.id + "' name='registration[participant_ids][]' id='registration_participant_ids_'>";
                        list += "<span>" + item.participant.first_name + " " + item.participant.middle_name + " " + item.participant.last_name + "</span></li>"
                    });
                    list += "</ul>";
                    $("#list_here").html(list);
                }
                else {
                    $("#list_here").html("<center><p class='notify'>No students are added in this centre.</p></center>");
                }
            }
        });
    });
    
    $('input[name="participant[is_bk]"]').click(function(){
        var val = $(this).val();
        if (val == '0') {
            $('#bk_req_1').hide();
            $('#bk_req_2').hide();
            
            $('#participant_in_gyan').val('0');
            $('#participant_in_purity').val('0');
            $('#participant_in_food').val('0');
            $('#participant_in_murli').val('0');
        }
        else {
            $('#bk_req_1').show();
            $('#bk_req_2').show();
            
            $('#participant_in_gyan').val('1');
            $('#participant_in_purity').val('1');
            $('#participant_in_food').val('1');
            $('#participant_in_murli').val('1');
        }
    });
    
    $('#regSort').change(function(){
        var val = $(this).val();
        if (val == "byID") {
            $('#reg_by_events').hide();
            $('#reg_by_ids').show();
        }
        else {
            $('#reg_by_ids').hide();
            $('#reg_by_events').show();
        }
    });
    
});


/* Add Rows */

function Toggle(node){
    var trNode = node;
    var mynode = trNode.charAt(2);
    var i = 0;
    
    if (!$("#" + trNode).is(':visible')) {
        var trImg = "img" + mynode;
        $("#" + trImg).attr({
            src: "/images/minus.gif",
            alt: "Remove"
        });
        $("#" + trNode).show();
    }
    else {
        for (i = mynode; i < 6; i++) {
            trNode = "tr" + i;
            trImg = "img" + i;
            trReturn = "return-" + i;
            trDdate = "ddate-" + i;
            trDepby = "depby-" + i;
            trName = "name-" + i;
            trVehicle = "vehicle-" + i;
            trTime = "time-" + i;
            $("#" + trNode).hide();
            $("#" + trImg).attr({
                src: "/images/plus.gif",
                alt: "Add"
            });
            $("#" + trReturn).val('');
            $("#" + trDdate).val('');
            $("#" + trDepby).val('');
            $("#" + trName).val('');
            $("#" + trVehicle).val('');
            $("#" + trTime).val('');
        }
    }
}

function trim(str){
    return str.replace(/^\s+|\s+$/g, "");
}

function check_email(email){
    var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
    if (reg.test(email)) {
        return true;
    }
    return false;
}

function IsNumeric(sText){
    var ValidChars = "0123456789.";
    var IsNumber = true;
    var Char;
    
    for (i = 0; i < sText.length && IsNumber == true; i++) {
        Char = sText.charAt(i);
        if (ValidChars.indexOf(Char) == -1) {
            IsNumber = false;
        }
    }
    return IsNumber;
}

function checkTotal(id){
    if (id == 'registration_bk_bro' || id == 'registration_nbk_bro') {
        var val1 = parseInt($("#registration_bk_bro").val());
        var val2 = parseInt($("#registration_nbk_bro").val());
        val1 = (isNaN(val1)) ? 0 : val1;
        val2 = (isNaN(val2)) ? 0 : val2;
        total = val1 + val2;
        $("#registration_total_bro").val(total);
    }
    else 
        if (id == 'registration_bk_sis' || id == 'registration_nbk_sis') {
            var val1 = parseInt($("#registration_bk_sis").val());
            var val2 = parseInt($("#registration_nbk_sis").val());
            val1 = (isNaN(val1)) ? 0 : val1;
            val2 = (isNaN(val2)) ? 0 : val2;
            total = val1 + val2;
            $("#registration_total_sis").val(total);
        }
        else 
            if (id == 'registration_bk_teachers') {
                var val1 = parseInt($("#registration_bk_teachers").val());
                val1 = (isNaN(val1)) ? 0 : val1;
                total = val1;
                $("#registration_total_teachers").val(total);
            }
    var t1 = parseInt($("#registration_total_bro").val());
    var t2 = parseInt($("#registration_total_sis").val());
    var t3 = parseInt($("#registration_total_teachers").val());
    var t4 = parseInt($("#registration_children").val());
    t3 = (isNaN(t3)) ? 0 : t3;
    t4 = (isNaN(t4)) ? 0 : t4;
    total = t1 + t2 + t3 + t4;
    $("#registration_grand_total").val(total);
}

function customRange(input){
    return {
        minDate: (input.id == "ddate-1" ? $("#adate").datepicker("getDate") : null),
        maxDate: (input.id == "adate" ? $("#ddate-1").datepicker("getDate") : null)
    };
}

function customRange2(input){
    return {
        minDate: (input.id == "event_end_date" ? $("#event_start_date").datepicker("getDate") : null),
        maxDate: (input.id == "event_start_date" ? $("#event_end_date").datepicker("getDate") : null)
    };
}
