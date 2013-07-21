class Csv < ActiveRecord::Base
	
	def self.save(upload, selected_year, selected_month)
		tmp = upload.tempfile
		stringified_date = stringify_date(selected_year, selected_month)
		file = File.join("public/csv", stringified_date + ".csv")

		FileUtils.cp tmp.path, file
		File.chmod(644, file)
		csv = Csv.new 
		csv.image_file_location = "infographs/#{stringified_date}.png"
		csv.csv_file_location = "csv/#{stringified_date}.csv"
		csv.date = stringified_date
		csv.save
	end

	def self.stringify_date(selected_year, selected_month)
		"#{selected_year}-#{selected_month}"
	end
end