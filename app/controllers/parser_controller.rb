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
		
		vc = parsed_string[:victim_characteristics]
		characteristict_sum = vc.values.inject{|sum, value| sum.to_i + value.to_i}
		@vc = calculate_victim_characteristics(vc, characteristict_sum)

		@since_year = parsed_string[:general_info][:since_year]
		@since_month = parsed_string[:general_info][:since_month]
		@since_incidents = parsed_string[:general_info][:since_incidents]
		@since_responses = parsed_string[:general_info][:since_responses]

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

	private

	def percent_of(a, b)
		a.to_f / b.to_f * 100.0
	end

	def calculate_victim_characteristics(vc, characteristict_sum)
		
		max_v_1 = vc.values.map{|v| v.to_i}.max 
		max_n_1 = vc.key max_v_1.to_s
		max_v_1 = percent_of(max_v_1, characteristict_sum)
		vc.delete max_n_1

		max_v_2 = vc.values.map{|v| v.to_i}.max 
		max_n_2 = vc.key max_v_2.to_s
		max_v_2 = percent_of(max_v_2, characteristict_sum)
		vc.delete max_n_2

		max_v_3 = vc.values.map{|v| v.to_i}.max 
		max_n_3 = vc.key max_v_3.to_s
		max_v_3 = percent_of(max_v_3, characteristict_sum)
		vc.delete max_n_3
		
		return { :first => {stringify_vc(max_n_1) => max_v_1}, :second => {stringify_vc(max_n_2) => max_v_2}, :third => {stringify_vc(max_n_3) => max_v_3}, :others => percent_of(vc.values.map{|v| v.to_i}.sum, characteristict_sum)}
	end

	def stringify_vc(string)
		splitted = string[3..-1].split('_')
		unless splitted[2].nil?
			splitted.delete_at(2)
		end
		return splitted.join('<br />')
	end

end