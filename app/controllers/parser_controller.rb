require 'timeout'
require 'net/http'
require 'open-uri'
require 'fileutils'

class ParserController < ApplicationController	
	
	def parse
		@string = params[:csv]
	end

	def rasterize
		aws_ip = "54.218.15.104"
		file_name = params[:file_name]
		csv = params[:csv]

		begin 
			# => Ping rasterization job with data provided
			Timeout.timeout(15) do
				s = Net::HTTP.get(URI.parse("http://#{aws_ip}/invoke_rasterization?file_name=#{file_name}&csv=#{csv}"))
				puts "respond : #{s}"
				@error = false
			end
		rescue Errno::ECONNREFUSED
			@error = "Connection refused"
			return true
		rescue Timeout::Error
			@error = "Timeout error"
			return false
		rescue Exception => e
			@error = "Unknown error has ocured \n #{e}"
			return false
		end

	end

	def show_image
		aws_ip = "54.218.15.104"
		file_name = params[:file_name]
		local_file = "public/images/infographs/#{file_name}.png"

		# => Download image locally
		open(local_file, 'wb') do |file|
		  file << open("http://#{aws_ip}/images/infographs/#{file_name}.png").read
		end
		sleep(1)
		@image_local = "images/infographs/#{file_name}.png"
	end
end