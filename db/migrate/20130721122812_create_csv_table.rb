class CreateCsvTable < ActiveRecord::Migration
  def self.up
  	create_table :csvs do |c|
  		c.string	:image_file_location
  		c.string	:csv_file_location
  		c.string	:date
  	end
  end

  def self.down
  	drop_table :csvs
  end
end
