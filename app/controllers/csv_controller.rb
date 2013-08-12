class CsvController < ApplicationController
	
	def index
		csvs = CsvData.all
		@years = {}
		csvs.each do |csv|
			unless @years.has_key?(csv.year)
				@years[csv.year] = []
			end
			@years[csv.year] << csv.month
		end
	end

	def upload_file
		selected_year = params[:year]
		selected_month = params[:month]
		CsvData.save(params[:upload_file][:the_file], selected_year, selected_month)
		
		redirect_to dashboard_path()
	end
end