class ParticipantController < ApplicationController
  require 'will_paginate'
  require 'spreadsheet'
  before_filter :authorize
  
  def index
    render :action => 'list'
  end
  
  def upload
    
  end
  
  def new
    @participant = Participant.new()
  end
  
  def list
    @user = current_user
    items_per_page = 30
    
    sort = case params[:sort]
      when "category"  then "category"
      when "firstname" then "first_name"
      when "lastname"  then "last_name"
      when "age"       then "age"
      when "gyan"      then "in_gyan"
    else "id"
    end
    if @user.id == 1 && @user.centre_id == 4068 && params[:id] != nil
      @registration = Registration.find(params[:id])
      @participants = Participant.find(@registration.participants).paginate :per_page => items_per_page, :page => params[:page], :order => sort
    else
      @participants = Participant.paginate :per_page => items_per_page, :page => params[:page], :order => sort,
        :conditions => ["centre_id = ?", current_user.centre_id]
    end

  end
  
  def show
    @user = current_user
    @participant  = Participant.find(params[:id])

    if @user.id == 1 && @user.centre_id == 4068
    else
      if @participant.centre_id != current_user.centre_id
        flash[:notice] = 'Unknown Participant'
        redirect_to :action => 'list'
      end
    end

    @participant  = Participant.find(params[:id])
  end
  
  def create
    @user     = current_user
    @address  = Address.new(params[:address])
    @contact  = Contact.new(params[:contact])
    params[:participant][:centre_id] = @user.centre_id
    @participant  = Participant.new(params[:participant])
    if @address.save
      if @contact.save
        @participant.address = @address
        @participant.contact = @contact
        
        last_participant = Participant.last(:conditions => ["centre_id = ?", current_user.centre_id])
        no = last_participant.rollno.split('-')[1]
        rollno = no.to_i + 1
        @participant.rollno = "#{@user.centre.id}-#{rollno}"
        
        if @participant.save
          flash[:notice] = 'Participant details successfully added to contacts list.'
          redirect_to :action => 'list'
        else
          @address.destroy
          @contact.destroy
          render :action => 'new'
        end
      else
        @address.destroy
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end
  
  def edit
    @participant = Participant.find(params[:id])
    if @participant.centre_id == current_user.centre_id
      @address = Address.find(@participant.address)
      @contact = Contact.find(@participant.contact)
    else
      flash[:notice] = 'Unknown Participant'
      redirect_to :action => 'list'
    end
  end
  
  def update
    @participant = Participant.find(params[:id])
    if @participant.centre_id == current_user.centre_id
      @address = Address.find(@participant.address)
      @address.update_attributes(params[:address])
      @contact = Contact.find(@participant.contact)
      @contact.update_attributes(params[:contact])
      if @participant.update_attributes(params[:participant])
        flash[:notice] = 'Participant details updated successfully.'
        redirect_to :action => 'show', :id => @participant
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Unknown Participant'
      redirect_to :action => 'list'
    end
  end
  
  def delete
    @participant = Participant.find(params[:id]).destroy
    if @participant.centre_id == current_user.centre_id
      Address.find(@participant.address).destroy
      Contact.find(@participant.contact).destroy
      flash[:notice] = 'Participant details are deleted.'
    else
      flash[:notice] = 'Unknown Participant'
    end
    redirect_to :action => 'list'
  end
  
  def get_list
    @user = current_user
    if @user.id == 1 && @user.centre_id == 4068
      @participants = Participant.find(:all, :select => "id, first_name, last_name, middle_name", :conditions => ["centre_id = ?", params[:centre_id]], :order => "first_name, last_name")
      render :json => @participants.to_json
    else
      render :json => {:status => false}.to_json
    end
  end

  def uploadexcel
    excel_file = params[:upload_excel][:excel_file]
    content_type = excel_file.content_type.chomp
    if (content_type == "application/vnd.ms-excel")
    file_name = excel_file.original_filename
    path_to_file = _save_file( excel_file ,  file_name)
    @participants = _extract_data_from_file(path_to_file)
    else
     # redirect_to error page
    end
    if (false) 
        File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'w') do |file|
          file.write(uploaded_io.read)
        end
        @user     = current_user
        book = Spreadsheet.open("public/uploads/#{uploaded_io.original_filename}", "r")
        sheet1 = book.worksheet 0
        sheet1.each_with_index  do |row, index|
        puts row.length
        puts index
        if index > 0
        @participant = Participant.new()
        @contact = Contact.new()
        @address  = Address.new()
        @participant.centre_id = @user.centre_id
        row.each_with_index do |column,column_index|
#puts column
        puts column_index
        if column_index == 0
        @participant.category = column
        elsif column_index == 1
        @participant.first_name = column
        elsif column_index == 2
        @participant.last_name = column
        elsif column_index == 3
        @participant.is_bk = true
        elsif column_index == 4
        @participant.age = column
        elsif column_index == 5
        @address.addr1 = column
        elsif column_index == 6
        @address.city = column
        elsif column_index == 7
        @address.state = column
        elsif column_index == 8
        @address.pincode = column.to_i
        elsif column_index == 9
        @address.country = column
        elsif column_index == 10
        @participant.in_gyan = column
        elsif column_index == 11
        @participant.in_purity = column
        elsif column_index == 12
        @participant.in_food = column
        elsif column_index == 13
        @participant.in_murli = column
        elsif column_index == 14
        @participant.nationality = column
        end
        end
#        if @address.save
#        if @contact.save
        @participant.address = @address
        @participant.contact = @contact

        no = Participant.count(:conditions => ["centre_id = ?", current_user.centre_id])
        rollno = no.to_i + 1
        @participant.rollno = "#{@user.centre.id}-#{rollno}"
        @participant.middle_name = ""
#        @participant.save
#        else
#        @address.destroy
#        end
#        end


#raise @participant.inspect
        end
        end

#puts "Excel Upload"
#        redirect_to :action => 'list'

     end
  end

private

  def _save_file(filepath, original_name)
    directory = "public/uploads/participant_excel_files"
    # create the file path
    path = File.join(directory,original_name)
    # write the file
    File.open(path, "wb") { |f| f.write(filepath.read) }
    return path
  end

  def _extract_data_from_file(path_to_file)
    book = Spreadsheet.open path_to_file
    @sheet1 = book.worksheet 0
    first_row = @sheet1.row(0)
    participants = []
    if (_check_first_row(first_row))
      @sheet1.each 1 do |row|
        participants.insert(-1,_add_data_to_db(row))
      end
    else
      redirect_to(:error)
    end
    return participants
  end  

  def _check_first_row(first_row)
#    Gold = ["First Name", "Last Name", "Gender", "Center Name", "City"]
#    if (first_row == Gold)
      return true
#    else
#      return false
#    end
  end

  def _add_data_to_db(row)
    participant = Participant.new
    participant.category = row[0]
    participant.first_name = row[1]
    participant.last_name = row[2]
    participant.last_name = row[2]
    participant
  end
end
