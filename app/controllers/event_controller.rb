class EventController < ApplicationController
  require 'spreadsheet'
  require 'action_mailer'

  before_filter :authorize

  def index
    redirect_to :action => 'list'
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = 'Event details added successfully.'
      redirect_to :action => 'list'
    else
      flash[:notice] = '#ERROR#Something went wrong, please check all fields and try again.'
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def list
    items_per_page = 50
    @user = current_user
    @events = Event.paginate :per_page => items_per_page, :page => params[:page], 
                             :order => "start_date desc, end_date desc"
  end

  def update
    @event = Event.find(params[:id])
    if @event
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event details updated successfully.'
        redirect_to :action => 'list'
      else
        flash[:notice] = '#ERROR#Something went wrong, please check all fields and try again.'
        render :action => 'edit'
      end
    else
      flash[:notice] = '#ERROR#Unknown Event'
      redirect_to :action => 'list'
    end
  end

  def delete
    @user = current_user
    @event = Event.find(params[:id])
    if @event
      @event.destroy
      flash[:notice] = 'Event deleted'
    else
      flash[:notice] = '#ERROR#Unknown Event'
    end
    redirect_to :action => 'list'
  end

  def set_status
    @event = Event.find(params[:id])
    if @event
      @event.update_attribute(:active,params[:active])
    end
    render :json => {:status => true}.to_json
  end

  def downloadRegistrationDetails
     participant_cat = params[:participant][:category]
     event_id = params[:event][:event_id]
     event_name = Event.find(:first,:conditions => ["id = ?", event_id]).event_name
     list_name = "#{participant_cat}_#{event_id}.xls"
     list_book = Spreadsheet::Workbook.new
     list_sheet = list_book.create_worksheet(:name => "#{participant_cat}")
     query = "SELECT participants.first_name, participants.last_name, participants.age, participants.education, participants.surrender_year,\ 
       participants.in_gyan, addresses.addr1, centres.name, centres.id, zones.name\ 
       FROM participants, centres, zones, addresses\ 
       WHERE participants.id IN (SELECT distinct participant_id FROM participants_registrations\ 
       WHERE registration_id IN(SELECT registrations.id FROM registrations WHERE registrations.event_id = #{event_id}))\ 
       AND participants.category = '#{participant_cat}'"
       #ORDER BY zones.name, centres.name, addresses.addr1, participants.first_name"

     participants=Participant.find_by_sql(query)
#     centres=Centre.find_by_sql(query)
#     zones=Zone.find_by_sql(query)
#     addresses=Address.find_by_sql(query)
     if participants.length == 0  
        flash[:notice] = "#ERROR#No '#{participant_cat}' registered for the event '#{event_name}' !!"
	redirect_to :action => 'list'
     else 
        write_excel(list_sheet, participants)   
	list_book.write "#{RAILS_ROOT}/public/downloads/#{list_name}"
	list_path = "#{RAILS_ROOT}/public/downloads/#{list_name}"
	send_file list_path, :type => 'application/vnd.ms-excel'
     end	 
  end

  private
  
  def write_excel(list_sheet, participants)
     row_counter = 0
     list_sheet.row(row_counter).default_format = Spreadsheet::Format.new(:weight=>"bold",:color=>"red",:pattern  => 1,:pattern_fg_color => "yellow")
#     list_sheet.row(row_counter).insert 3, event_name
     row_counter += 2
     list_sheet.row(row_counter).default_format = Spreadsheet::Format.new(:weight=>"bold")
     list_sheet.row(row_counter).insert 0, "S.No."
     list_sheet.row(row_counter).insert 1, "NAME"
     list_sheet.row(row_counter).insert 2, "AGE"
     list_sheet.row(row_counter).insert 3, "EDUCATION"
     list_sheet.row(row_counter).insert 4, "SURRENDER YEAR"
     list_sheet.row(row_counter).insert 5, "IN GYAN(YRS)"
     list_sheet.row(row_counter).insert 6, "CENTER ADDRESS"
     list_sheet.row(row_counter).insert 7, "CENTER NAME"
     list_sheet.row(row_counter).insert 8, "ZONE"

     participants.length.times do |serial_no|
       row_counter += 1 
       list_sheet.row(row_counter).insert 0, (serial_no+1)
       name = participants[serial_no].first_name.nil? ? '' : participants[serial_no].first_name
       name = participants[serial_no].last_name.nil? ? name : name + ' ' + participants[serial_no].last_name
       list_sheet.row(row_counter).insert 1, name
       list_sheet.row(row_counter).insert 2, participants[serial_no].age
       list_sheet.row(row_counter).insert 3, participants[serial_no].education
       list_sheet.row(row_counter).insert 4, participants[serial_no].surrender_year
       list_sheet.row(row_counter).insert 5, participants[serial_no].in_gyan
#       list_sheet.row(row_counter).insert 6, addresses[serial_no].addr1
#       list_sheet.row(row_counter).insert 7, Centre.find_by_id(centres[serial_no].id).name
#       list_sheet.row(row_counter).insert 8, zones[serial_no].name
     end
  end
end
