class RegistrationController < ApplicationController
  require 'mime/types'
  require 'spreadsheet'
  require 'action_mailer'
  
  protect_from_forgery :except => :upload
  before_filter :authorize, :except => :upload
  layout 'application', :except => [:print_slip, :print_details]
  
  def index
    render :action => 'new'
  end

  def new
    @user = current_user
    @registration = Registration.new
    @centres  = Centre.find(:all, :order => "name")
    @events   = Event.find(:all, :conditions => ["active = ?", 1], :order => "start_date asc")
    @trains   = Train.find(:all, :order => "trnno")
    @participants_bk_bro =  Participant.find(:all, :conditions => ["category = ? and centre_id = ? and is_bk = ?", "brother", current_user.centre_id, "1" ],  :order => "first_name, last_name")
    @participants_bk_sis =  Participant.find(:all, :conditions => ["category = ? and centre_id = ? and is_bk = ?", "sister", current_user.centre_id, "1" ],  :order => "first_name, last_name")
    @participants_nbk_bro =  Participant.find(:all, :conditions => ["category = ? and centre_id = ? and is_bk = ?", "brother", current_user.centre_id, "0" ],  :order => "first_name, last_name")
    @participants_nbk_sis =  Participant.find(:all, :conditions => ["category = ? and centre_id = ? and is_bk = ?", "sister", current_user.centre_id, "0" ],  :order => "first_name, last_name")
    @participants_teachers =  Participant.find(:all, :conditions => ["category = ? and centre_id = ? and is_bk = ?", "teacher", current_user.centre_id, "1" ],  :order => "first_name, last_name") 

    @validate_users = 1
    if @user.id == 1 && @user.centre_id == 4068
      @validate_users = 0
    end
  end
  
  def edit
    @user = current_user
    @registration = Registration.find(params[:id])
    if @registration.centre_id == @user.centre_id
      @centres  = Centre.find(:all, :order => "name")
      @events   = Event.find(:all, :conditions => ["active = ?", 1], :order => "start_date asc")
      @trains   = Train.find(:all, :order => "trnno")
      @participants = Participant.find(:all, :conditions => ["centre_id = ?", current_user.centre_id], :order => "first_name, last_name")
      @travels = TravelInfo.find(:all, :conditions => ["registration_id = ?", params[:id]])
    else
      flash[:notice] = '#ERROR#Unknown Registration.'
      if @user.id == 1 && @user.centre_id == 4068
        redirect_to :action => 'all'
      else
        redirect_to :action => 'list'
      end
    end
  end
  
  def list
    items_per_page = 10
    @user = current_user
    @registrations = Registration.paginate :per_page => items_per_page, :page => params[:page], 
                                           :conditions => ["centre_id = '#{@user.centre_id}'"], 
                                           :include => [:event], 
                                           :order => "events.end_date desc"
    @trains = Train.find(:all, :order => "trnno")
  end
  
  def all
    @user = current_user
    if @user.id == 1 && @user.centre_id == 4068
      items_per_page = 40
      @registrations = Registration.paginate :per_page => items_per_page, :page => params[:page], 
                                             :include => [:event], 
                                             :order => "events.end_date desc"
      @registrations_by_id = Registration.paginate :per_page => items_per_page, :page => params[:page], 
                                             :include => [:event], 
                                             :order => "id desc"
      @trains = Train.find(:all, :order => "trnno")
    else
      redirect_to :action => 'list'
    end
  end
  
  def update
    params[:registration][:participant_ids] ||= []
    @registration = Registration.find(params[:id])
    if @registration
      flash[:notice] = 'Registration is successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
  
  def print_slip
    begin
      @status = 'valid'
      @user = current_user
      @registration = Registration.find(params[:id])    
      if @registration.centre_id != @user.centre_id
        @status = 'invalid'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => "Unknown registration number"
    end
  end
  
  def print_details
    begin
      @status = 'invalid'
      @user = current_user
      if @user.id == 1 && @user.centre_id == 4068
        @registration = Registration.find(params[:id])
        @travel = TravelInfo.find(:all, :conditions => ["registration_id = ?", params[:id]])
        @trains = Train.find(:all, :order => "trnno")
        @status = 'valid'
      end
    rescue ActiveRecord::RecordNotFound
      render :text => "Unknown registration number"
    end
  end
  
  def show
    @user = current_user
    @registration = Registration.find(params[:id])
    if @registration.centre_id == @user.centre_id
      @travel = TravelInfo.find(:all, :conditions => ["registration_id = ?", params[:id]])
      @trains = Train.find(:all, :order => "trnno")
    else
      flash[:notice] = '#ERROR#Unknown Registration'
      redirect_to :action => 'list'
    end
  end
  
  def view
    @user = current_user
    @registration = Registration.find(params[:id])
    if @user.id == 1 && @user.centre_id == 4068
      @travel = TravelInfo.find(:all, :conditions => ["registration_id = ?", params[:id]])
      @trains = Train.find(:all, :order => "trnno")
    else
      flash[:notice] = '#ERROR#Unknown Registration'
      redirect_to :action => 'list'
    end
  end
  
  def reply
    @user = current_user
    if @user.id == 1 && @user.centre_id == 4068
      @registration = Registration.find(params[:rid])
      if params[:status] == '1'
        @registration.status = 1
      else
        @registration.status = 2
      end
      @registration.save
      
      user = User.find(:first, :conditions => ["centre_id = ?", @registration.centre_id])
      if user
        Mailsender.deliver_reply_message(user.username, params[:msg], @registration.event.event_name)
        render :json => {:status => true, :result => "Mail has been sent to #{user.username}"}.to_json
      end
    end
  end
  
  def create
    @user = current_user
    
    if @user.id != 1 && @user.centre_id != 4068
      params[:registration][:centre_id]  = @user.centre_id
    end
    
    params[:registration][:created_on] = Time.now
    @registration = Registration.new(params[:registration])
    if @registration.save
      if(params[:travel_info1] && params[:travel_info1][:no_of_returns] != "")
        @info1 = TravelInfo.new(params[:travel_info1])
        @info1.registration = @registration
        @info1.save
      end
      @user = User.find(:first, :conditions => ['centre_id = ?', @registration.centre_id])
      @trains = Train.find(:all, :order => "trnno")
      Mailsender.deliver_new_registration(@registration, @trains, @user.username)
      flash[:notice] = 'Registration is successfully created.<br/><span class="req">You need to take corresponding <b>registration slip and form print out</b> when you are coming to attend any program.</span>'
      redirect_to :action => 'list'
    else
      flash[:notice] = '#ERROR#Registration unsuccessfull, please try again.'
      render :action => 'new'
    end
  end
  
  def delete
    @user = current_user
    @registration = Registration.find(params[:id])
    if @registration.centre_id == @user.centre_id
      TravelInfo.destroy_all(:registration_id => @registration.id)
      @registration.destroy
      flash[:notice] = 'Registration deleted'
    else
      flash[:notice] = '#ERROR#Unknown Registration'
    end
    redirect_to :action => 'list'
  end
  
  def download
    begin
      @user = current_user
      @registration = Registration.find(params[:id])
      if @registration.centre_id == @user.centre_id
        @participants = Participant.find(:all, :conditions => ["id IN (?)", @registration.participant_ids])
        @travel = TravelInfo.find(:first, :conditions => ["registration_id = ?", @registration.id])
        if @travel
          @train = Train.find(:first, :conditions => ["id = ?", @travel.departure_by])
        end
        
        registration_no = @registration.id.to_s
        
        #Spreadsheet.client_encoding = 'UTF-16LE'
        book = Spreadsheet.open "#{RAILS_ROOT}/public/downloads/Registration_Form.xls"
        #Spreadsheet.client_encoding = book.encoding
        format = Spreadsheet::Format.new :color => :navy, :weight => :bold
        
        sheet1 = book.worksheet 0
        sheet1.name = "Registration Details"
        
        sheet1.row(1).insert 2, "#{registration_no}"
        sheet1.row(3).insert 2, "#{@registration.event.event_name}"
        sheet1.row(5).insert 2, "#{@registration.guide_name}"
        sheet1.row(7).insert 2, "#{@registration.centre.name}"
        sheet1.row(7).insert 6, "Zone"
        sheet1.row(7).insert 7, "#{@registration.centre.zone.name}"
        sheet1.row(5).insert 6, "Contact No."
        
        i = 11
        j = 0
        gender = ""
        no_of_sisters  = 0
        no_of_brothers = 0
        no_of_teachers = 0
        for participant in @participants
          i += 1
          j += 1
          
          add_year = increment_year(participant.updated_at)
          
          sheet1.row(i).insert 0, j
          sheet1.row(i).insert 1, "#{participant.first_name} #{participant.last_name}"
          sheet1.row(i).insert 2, "#{participant.age + add_year}"
          gender = participant.category
          if gender == "Sister"
            gender = "F"
            no_of_sisters += 1
          elsif gender == "Teacher"
            gender = "F"
            no_of_teachers += 1
          elsif gender == "Brother"
            gender = "M"
            no_of_brothers += 1
          end
          sheet1.row(i).insert 3, "#{gender}"
          sheet1.row(i).insert 4, "#{participant.in_purity + add_year}"
          addr = participant.address.addr1
          addr = participant.address.addr2.nil? ? addr : addr + " " + participant.address.addr2
          addr = addr + " " + participant.address.city + " " + participant.address.state + " " + participant.address.pincode

          sheet1.row(i).insert 5, "#{addr}"
          sheet1.row(i).insert 6, "#{@registration.arrival_date.strftime('%d-%m-%Y')}"
          if @travel
            sheet1.row(i).insert 7, "#{@travel.departure_date.strftime('%d-%m-%Y')}"
          end
          if @train
            sheet1.row(i).insert 8, "#{@train.trnno}"
          end
        end
        
        i += 3
        sheet1.row(i).default_format = format
        sheet1.row(i).insert 1, "Brothers"
        sheet1.row(i).insert 2, "#{no_of_brothers}"
        sheet1.row(i).insert 5, "Sisters"
        sheet1.row(i).insert 6, "#{no_of_sisters}"
        sheet1.row(i).insert 8, "Teachers"
        sheet1.row(i).insert 9, "#{no_of_teachers}"
        
        i += 3
        sheet1.row(i).insert 1, "Total"
        sheet1.row(i).insert 2, "#{j}"
        sheet1.row(i).insert 8, "Signature"
        
        file = "Registration_Form_#{registration_no}.xls"
        book.write "#{RAILS_ROOT}/public/downloads/#{file}"
        
        file_path = "#{RAILS_ROOT}/public/downloads/#{file}"
        send_file file_path, :type => 'application/vnd.ms-excel'
      else
        render :text => "Unknown registration number"
      end
    rescue ActiveRecord::RecordNotFound
      render :text => "Unknown registration number"
    end
  end
  
  def upload
    if params[:Filedata]
      name = params[:Filedata].original_filename
      directory = "#{RAILS_ROOT}#{params[:folder]}"
      path = File.join(directory, name)
      
      File.open(path, "wb") { |f| f.write(params[:Filedata].read) }
      render :text => 'File has been uploaded'
    end
  end 
 
  def manage_trains
    @train_names = Train.find(:all,:order =>'trnname')
    #render :text => "Manage trains here..." 
  end
  
  def delete_train
    train = Train.find_by_id(params[:trains][:name])
    if Train.find_by_id(params[:trains][:name]).delete.save 
       flash[:notice] = " Train '#{train.trnname}' has been deleted !!"
    else
       flash[:notice] = "#ERROR#Error in deleting train '#{train.trnno}' !!"
    end 
    redirect_to :action => 'manage_trains'
  end

  def add_train
    train_no = params[:train][:no]
    train_name = params[:train][:name]
    train_time = params[:train][:train_timeHH] + ":" + params[:train][:train_timeMM] + ":00"
    train_days_ar = []
    train_days_ar.push("Mon") if params[:Mon] == "on"
    train_days_ar.push("Tue") if params[:Tue] == "on"
    train_days_ar.push("Wed") if params[:Wed] == "on"
    train_days_ar.push("Thu") if params[:Thu] == "on"
    train_days_ar.push("Fri") if params[:Fri] == "on"
    train_days_ar.push("Sat") if params[:Sat] == "on"
    train_days_ar.push("Sun") if params[:Sun] == "on"
    train_days = train_days_ar.join(", ")
    train_days = "Daily" if train_days_ar.length == 7
    
    if train_no == '' then flash[:notice] = "#ERROR#Train number can't be blank !!"
    elsif train_name == '' then flash[:notice] = "#ERROR#Train Name can't be blank !!"
    elsif train_days == '' then flash[:notice] = "#ERROR#Select at least one week day !!"
    elsif ! Train.new(:trnno=>train_no, :trnname=>train_name, :departure=>train_time, :days=>train_days).save then flash[:notice] = "#ERROR#Error in adding train #{train_name} !!"
    else
      flash[:notice] = " Train '#{train_name}' has been added !!"
    end
    redirect_to :action => 'manage_trains'
  end

  private
  def increment_year(updated_date)
    add_year = 0
    
    updated_year = updated_date.strftime("%Y").to_i
    
    today = Time.now
    today_year = today.strftime("%Y").to_i
    
    if today_year > updated_year
      diff = (today - updated_date).round
      add_year = diff/(365 * 24 * 60 * 60)
    end
    
    return add_year
  end
  
end
