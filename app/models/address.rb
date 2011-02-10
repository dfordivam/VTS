class Address < ActiveRecord::Base
  def validate
    errors.add_to_base("Address Line 1 can't be blank") if addr1.blank?
    errors.add_to_base("City can't be blank") if city.blank?
    errors.add_to_base("State can't be blank") if state.blank?
    errors.add_to_base("Pincode can't be blank") if pincode.blank?
    errors.add_to_base("Country can't be blank") if country.blank?
  end

  validates_length_of :pincode, :maximum => 6
end
