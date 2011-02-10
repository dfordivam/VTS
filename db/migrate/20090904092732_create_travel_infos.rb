class CreateTravelInfos < ActiveRecord::Migration
  def self.up
    create_table :travel_infos do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :travel_infos
  end
end
