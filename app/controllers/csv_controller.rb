class CsvController < ApplicationController
	
	def index
		@csvs = Csv.all
	end

	def upload_file
		selected_year = params[:year]
		selected_month = params[:month]
		Csv.save(params[:upload_file][:the_file], selected_year, selected_month)
		
		redirect_to dashboard_path()
	end
end