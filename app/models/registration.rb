class Registration < ActiveRecord::Base
  belongs_to :event
  belongs_to :centre

  has_and_belongs_to_many :participants
end
