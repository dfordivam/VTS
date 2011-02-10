class ParticipantController < ApplicationController
  require 'will_paginate'
  
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
    items_per_page = 30
    
    sort = case params[:sort]
      when "category"  then "category"
      when "firstname" then "first_name"
      when "lastname"  then "last_name"
      when "age"       then "age"
      when "gyan"      then "in_gyan"
    else "rollno"
    end
    @participants = Participant.paginate :per_page => items_per_page, :page => params[:page], 
                                         :conditions => ["centre_id = ?", current_user.centre_id],
                                         :order => sort
  end
  
  def show
    @participant  = Participant.find(params[:id])
    if @participant.centre_id != current_user.centre_id
      flash[:notice] = 'Unknown Participant'
      redirect_to :action => 'list'
    end
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
        
        no = Participant.count(:conditions => ["centre_id = ?", current_user.centre_id])
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
  
end
