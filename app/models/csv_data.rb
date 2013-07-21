require 'csv'

class CsvData < ActiveRecord::Base
	
	def self.save(upload, selected_year, selected_month)
		tmp = upload.tempfile
		stringified_date = stringify_date(selected_year, selected_month)
		file = File.join("public/csv", stringified_date + ".csv")

		FileUtils.cp tmp.path, file
		
		csv = CsvData.new 
		csv.image_file_location = "infographs/#{stringified_date}.png"
		csv.csv_file_location = "csv/#{stringified_date}.csv"
		csv.date = stringified_date
		csv.save

		`chmod 644 #{file}`
	end

	def self.stringify_date(selected_year, selected_month)
		"#{selected_year}-#{selected_month}"
	end

	def self.parse(file_name)
		rafined_data = {}
		file_path = "public/csv/#{file_name}.csv"		
		
		raw_csv = CSV.read(file_path, {:headers => true, :col_sep => ";", :encoding => "ISO-8859-2"})		
		
		switcher = :general_info
		rafined_data[switcher] = {}
		raw_csv.each_with_index do |c, i|
			next if c["general_info"].nil?
			if c[nil].to_s.blank?
				switcher = c["general_info"].to_sym
				rafined_data[switcher] = {}
				next
			else
				rafined_data[switcher].merge!({c["general_info"].to_sym => c[nil].to_s})
			end
		end
		return rafined_data
	end
end