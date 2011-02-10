class EventController < ApplicationController

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
      flash[:notice] = 'Something went wrong, please check all fields and try again.'
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
        flash[:notice] = 'Something went wrong, please check all fields and try again.'
        render :action => 'edit'
      end
    else
      flash[:notice] = 'Unknown Event'
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
      flash[:notice] = 'Unknown Event'
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

end
