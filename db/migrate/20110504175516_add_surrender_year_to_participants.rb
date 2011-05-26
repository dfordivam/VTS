class AddSurrenderYearToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :surrender_year, :integer
  end

  def self.down
    remove_column :participants, :surrender_year
  end
end
