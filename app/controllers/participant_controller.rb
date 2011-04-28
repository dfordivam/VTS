class ParticipantController < ApplicationController
  require 'will_paginate'
  require 'spreadsheet'
  before_filter :authorize

  def index
    render :action => 'list'
  end

  def upload

  end

  def download 
    type = params[:type]
    if type == 'upload_templ'
      file = "upload_template.xls"
    end
    
    file_path = "#{RAILS_ROOT}/public/downloads/#{file}"
    send_file file_path, :type => 'application/vnd.ms-excel'
  end

  def new
    user     = current_user
    centre = Centre.find(user.centre_id)
    @address = Address.find(centre.address_id)
    @participant = Participant.new()
  end

  def list
    @user = current_user
    items_per_page = 30

    sort = case params[:sort]
           when "category"  then "category"
           when "is_bk"     then "is_bk"
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
    @address = Address.new(params[:address])
    @contact = Contact.new(params[:contact])
    @participant  = Participant.new(params[:participant])
    if (_add_data_to_db(@user.centre_id, @participant, @address, @contact))
      flash[:notice] = 'Participant details successfully added to contacts list.'
      redirect_to :action => 'list'
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
#    excel_file = params[:upload_excel][:excel_file]
    if (params[:upload_excel].nil? || params[:upload_excel][:excel_file].nil?)
      flash[:notice] = 'Please select a file by clicking chose file'
      redirect_to :action => 'list'
    else
    excel_file = params[:upload_excel][:excel_file]
    if (excel_file.content_type && excel_file.content_type.chomp == "application/vnd.ms-excel")
      @original_file_name = excel_file.original_filename
      @file_name = rand(999999).to_s + "-" + @original_file_name
      path_to_file = _save_file( excel_file ,  @file_name)
      @collections = _extract_data_from_file(path_to_file)
      @participants_1 = []
      @collections.each_with_index do |collection, index| 
        @participants_1[index] = collection[:participant]
      end
      items_per_page = 1000
      @participants = @participants_1.paginate  :per_page => items_per_page, :page => params[:page]
    else
      flash[:notice] = 'File type error. Please upload MS-Excel File'
      redirect_to :action => 'list'
    end
    end
  end

  def addDataFromExcel
    @user     = current_user
    @file_name = params[:file][:name]
    directory = "public/uploads/participant_excel_files"
    path = File.join(directory, @file_name)
    @collections = _extract_data_from_file(path)
    @count = 0
    @error = false
    @collections.each do |collection|
      @address = collection[:address]
      @contact = collection[:contact]
      @participant  = collection[:participant]
      if (_add_data_to_db(@user.centre_id, @participant, @address, @contact))
        @count = @count + 1
      else
        @error = true
        break
      end
    end

    if (@error)
      flash[:notice] = "There was some error adding participants. (#{@count} participants successfully added) "
    else
      flash[:notice] = "#{@count} Participant details successfully added to contacts list."
    end
      redirect_to :action => 'list'
    return
  end

  private

  def _add_data_to_db(user_centre_id, participant, address, contact)
    participant.centre_id = user_centre_id
    if address.save
      if contact.save
        participant.address = address
        participant.contact = contact

        last_participant = Participant.last(:conditions => ["centre_id = ?", user_centre_id])
        no = last_participant.rollno.split('-')[1]
        rollno = no.to_i + 1
        participant.rollno = "#{user_centre_id}-#{rollno}"

        if participant.save
          return true
        else
          address.destroy
          contact.destroy
          return false
        end
      else
        address.destroy
        return false
      end
    else
      return false
    end
  end

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
        participants.insert(-1,_retrieve_data(row))
      end
    else
      flash[:notice] = "Problem in first row of excel file. Please use the template file to upload the participants list."
      redirect_to :action => 'list'
    end
    return participants
  end  

  def _check_first_row(first_row)
    gold = ["Category","First Name", "Last Name" , "BK", "Age", "Address", "City", "State", "Country", "Years in Gyan", "Observing Purity (Years)", "Purity of Food (Years)", "Attending Murli Class (Years)","Profession (Optional)", "Mobile (Optional)"]
    if (first_row == gold)
      return true
    else
      return false
    end
  end

  def _retrieve_data(row)
    participant = Participant.new
    address = Address.new
    contact = Contact.new
    participant.category = _check_category(row[0])
    participant.first_name = row[1]
    participant.middle_name = ""
    participant.last_name = row[2]
    participant.is_bk = _check_is_bk(row[3])
    participant.age = row[4]
    address.addr1 = row[5]
    address.city = row[6]
    address.state = row[7]
    address.country = row[8]
    address.pincode = 999999
    participant.in_gyan = row[9]
    participant.in_purity = row[10]
    participant.in_food = row[11]
    participant.in_murli = row[12]
    participant.profession = row[13]
    contact.mobile = row[14]
    participant.rollno = "1"
    participant.nationality = "Indian"
    return {:participant => participant, :address => address, :contact => contact}
  end

  def _check_category(category)
    if (category.downcase == "brother" || category.downcase == "bro")
      return "Brother"
    elsif (category.downcase == "sister" || category.downcase == "sis") 
      return "Sister"
    elsif (category.downcase == "teacher")
      return "Teacher"
    else
      return "Brother"
    end

  end
  def _check_is_bk(is_bk)
    if (is_bk.downcase == "no")
      return 0
    else
      return 1
    end
  end

end
