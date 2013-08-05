class AddImageGeneratedToCsvDatas < ActiveRecord::Migration
  def self.up
  	add_column :csv_datas, :generated, :boolean, :default => false
  end

  def self.down
  	remove_column :csv_datas, :generated
  end
end
