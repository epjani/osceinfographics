class AddYearQuarterMonthToCsvData < ActiveRecord::Migration
  def self.up
  	add_column :csv_datas, :year, :integer
  	add_column :csv_datas, :quarter, :integer
  	add_column :csv_datas, :month, :integer
  end

  def self.down
  	remove_column :csv_datas, :year, :integer
  	remove_column :csv_datas, :quarter, :integer
  	remove_column :csv_datas, :month, :integer
  end
end
