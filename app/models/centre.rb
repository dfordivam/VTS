class Centre < ActiveRecord::Base
  belongs_to :zone
  belongs_to :address
  belongs_to :contact

  has_many :participant

  def validate
    errors.add_to_base("Zone Name can't be blank")        if zone_id.blank?
    errors.add_to_base("Centre Type can't be blank")      if centre_type.blank?
    errors.add_to_base("Centre Name can't be blank")      if name.blank?
    errors.add_to_base("Centre Incharge can't be blank")  if incharge.blank?
  end
end
