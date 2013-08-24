class CsvController < ApplicationController
	before_filter :authenticate	
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

	protected

	def authenticate
		authenticate_or_request_with_http_basic do |username, password|
		  username.downcase == 'osceadmin' && Digest::SHA256.hexdigest(password) == 'e2a085ffe8562304b7f42ba9e4da52a492dd5e9743dc991aeb7a773101c8e960'
		end
	end
end