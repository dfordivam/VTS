class Mailsender < ActionMailer::Base
  
  def reply_message(to, message, event)
    from = "accommodation.sv@bkivv.org"
    subject = "#{event} - Resigration Status"
    
    fail StandardError, "No Recipient" if to.empty?
    fail StandardError, "No Message"   if message.empty? 
    fail StandardError, "No Subject"   if subject.empty?
    
    recipients   to
    from         from
    subject      subject
    sent_on      Time.now
    body         :msg => message
  end
  
  def password_reset_instructions(user)
    recipients   user.username
    from         "accommodation.sv@bkivv.org"
    subject      "VTS Account Password Reset Instructions"
    sent_on      Time.now
    body         :password_reset_url => password_reset_url(user.perishable_token), :name => user.centre.incharge
  end
  
  def new_registration(registration, trains, email)
    recipients   "accommodation.sv@bkivv.org,bkraghukumar@gmail.com"
    from         email
    subject      "Registration Details : #{registration.id} from #{registration.centre.name}"
    sent_on      Time.now
    body         :registration => registration, :trains => trains
  end
  
end
