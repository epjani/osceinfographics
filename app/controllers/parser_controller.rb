require 'timeout'
require 'socket'

class ParserController < ApplicationController
	def parse
		@string = params[:csv]
	end

	def rasterize
		aws_ip = "54.218.15.104"
		file_name = params[:file_name]
		csv = params[:csv]
		begin 
			Timeout.timeout(5) do
				s = TCPSocket.new("http://#{aws_ip}/invoke_rasterization?file_name=#{file_name}&csv=#{csv}")
				s.close

				@error = "Everything went well"
				return true
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
end