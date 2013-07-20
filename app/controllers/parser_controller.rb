require 'timeout'
require 'socket'

class ParserController < ApplicationController
	def parse
		@string = params[:csv]
	end

	def rasterize
		aws_ip = "54.218.15.104"
		begin 
			Timeout.timeout(5) do
				s = TCPSocket.new("http://#{aws_ip}/invoke_rasterization")
				s.close

				puts "Everything went well"
				return true
			end
		rescue Errno::ECONNREFUSED
			puts "Connection refused"
			return true
		rescue Timeout::Error
			puts "Timeout error"
			return false
		rescue
			puts "Unknown error has ocured"
			return false
		end
	end
end