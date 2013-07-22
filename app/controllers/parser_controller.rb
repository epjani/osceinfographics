require 'timeout'
require 'net/http'
require 'open-uri'
require 'fileutils'

class ParserController < ApplicationController	
	
	def parse
		# => TODO invoke parser
		file_name = params[:file_name]
		parsed_string = CsvData.parse(file_name)
		puts "#{parsed_string}"
		@month = parsed_string[:general_info][:month]
		@year = parsed_string[:general_info][:year]
		@total_incidents = parsed_string[:general_info][:total_incidents]
		@total_responses = parsed_string[:general_info][:total_responses]
		@responses_to_incidents = parsed_string[:general_info][:responses_to_incidents]
		@monthly = parsed_string[:monthly_preview]
	end

	def rasterize
		aws_ip = "54.218.15.104"
		file_name = params[:file_name]
		csv = params[:csv]

		begin 
			#=> Ping rasterization service with data provided
			Timeout.timeout(5) do
				s = Net::HTTP.get(URI.parse("http://#{aws_ip}/invoke_rasterization?file_name=#{file_name}&csv=#{csv}"))
				@error = false
			end
		rescue Errno::ECONNREFUSED
			@error = "Connection refused"
			return true
		rescue Timeout::Error
			@error = true
		rescue Exception => e
			@error = "Unknown error has ocured \n #{e}"
			return true
		end
		sleep(3)
		redirect_to show_image_path(:file_name => file_name)
	end

	def show_image
		aws_ip = "54.218.15.104"
		file_name = params[:file_name]
		local_file = "public/images/infographs/#{file_name}.png"

		# => TODO check if images exist don't go and download it
		# => Download image locally
		open(local_file, 'wb') do |file|
		  file << open("http://#{aws_ip}/images/infographs/#{file_name}.png").read
		end
		sleep(4)
		@image_local = "images/infographs/#{file_name}.png"
	end
end