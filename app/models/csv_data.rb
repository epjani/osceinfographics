require 'csv'

class CsvData < ActiveRecord::Base
	
	# => TODO Parse data and store it in csv_datas after upload (not  during /parse request) @ line #25
	def self.save(upload, selected_year, selected_month)
		tmp = upload.tempfile
		tmp_file_name = "tmp_file"

		tmp_file = File.join("public/csv", tmp_file_name + ".csv")

		FileUtils.cp tmp.path, tmp_file
		`chmod 644 #{tmp_file}`

		csv = CsvData.new 
		csv.csv_file_location = "csv/#{tmp_file_name}.csv"
		csv.date = tmp_file_name

		parsed_data = CsvData.parse(tmp_file_name, false)
		year = parsed_data[:general_info][:year].to_i
		month = Date::MONTHNAMES.index(parsed_data[:general_info][:month])
		quarter = month <= 3 ? 1 : (month <= 6 ? 2 : ( month <= 9 ? 3 : 4))
		stringified_date = stringify_date(year, month)
		
		unless (CsvData.where(:date => stringified_date).count > 0)
			csv.image_file_location = "infographs/#{stringified_date}.png"
			csv.date = stringified_date
			csv.year = year
			csv.month = month
			csv.quarter = quarter
			csv.save
		end

		FileUtils.mv(tmp_file, File.join("public/csv", stringified_date + ".csv"))
		
	end

	def self.stringify_date(selected_year, selected_month)
		"#{selected_year}-#{selected_month}"
	end

	def self.parse(file_name, flag_as_generated = false)
		rafined_data = {}
		file_path = "public/csv/#{file_name}.csv"		
		
		begin
			raw_csv = CSV.read(file_path, {:headers => true, :col_sep => ",", :encoding => "UTF-8"})
		rescue
			raw_csv = CSV.read(file_path, {:headers => true, :col_sep => ",", :encoding => "ISO-8859-2"})
		end
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
	
		csv = CsvData.where(:date => file_name).first
		if csv
			csv.generated = true
			csv.save
		end
		return rafined_data
	end
end