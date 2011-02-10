class Participant < ActiveRecord::Base
  belongs_to :centre
  belongs_to :address
  belongs_to :contact

  has_and_belongs_to_many :registrations

  def validate
    errors.add_to_base("Category can't be blank")       if category.blank?
    errors.add_to_base("First Name can't be blank")     if first_name.blank?
    errors.add_to_base("Last Name can't be blank")      if last_name.blank?
    errors.add_to_base("Age can't be blank")            if age.blank?
    errors.add_to_base("Nationality can't be blank")    if nationality.blank?
    errors.add_to_base("Years in gyan can't be blank")  if in_gyan.blank?
  end
end
