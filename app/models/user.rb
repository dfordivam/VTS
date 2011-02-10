class User < ActiveRecord::Base
  acts_as_authentic

  attr_accessible :username, :email, :password, :password_confirmation

  belongs_to :centre

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Mailsender.deliver_password_reset_instructions(self)
  end

end
