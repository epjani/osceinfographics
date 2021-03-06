require 'open-uri'
require 'fileutils'

class ParserController < ApplicationController	

	before_filter :set_locale

	def parse
		# => TODO invoke parser
		file_name = params[:file_name]
		parsed_string = CsvData.parse(file_name)
		puts "#{parsed_string}"
		@month = parsed_string[:general_info][:month] 
		@year = parsed_string[:general_info][:year]
		@total_incidents = parsed_string[:general_info][:total_incidents_monthly]
		@total_responses = parsed_string[:general_info][:total_responses_monthly]
		@monthly = parsed_string[:monthly_preview]
		
		vc = parsed_string[:victim_characteristics]
		characteristict_sum = vc.values.inject{|sum, value| sum.to_i + value.to_i}
		@vc = calculate_victim_characteristics(vc, characteristict_sum)

		@since_year = parsed_string[:incidents_since][:since_year]
		@since_month = parsed_string[:incidents_since][:since_month]

		@since_incidents = parsed_string[:incidents_since][:since_incidents]
		@since_responses = parsed_string[:incidents_since][:since_responses]
		@since_responses_one = parsed_string[:incidents_since][:since_at_least_one_response]

		@incidents = parsed_string[:incidents]
		@responses = parsed_string[:responses]

		if I18n.locale == :en || I18n.locale == "en"
		@highlighted = parsed_string[:responses][:r_highlighted_action_en]
		end
		if I18n.locale == :bs || I18n.locale == "bs"
		@highlighted = parsed_string[:responses][:r_highlighted_action_bs]
		end

		@cases_ongoing = parsed_string[:hate_crimes_cases_in_a_year][:trials_ongoing]
		@convictions = parsed_string[:hate_crimes_cases_in_a_year][:convictions]
		@acquittals = parsed_string[:hate_crimes_cases_in_a_year][:acquittals]

		@cities = parsed_string[:geographical_presentation_responses]
		@graphical_cities = calculate_graphical_data(parsed_string[:geographical_presentation_incidents], parsed_string[:geographical_presentation_responses])
		
		@prevention = parsed_string[:prevention]
		
		@render_map = @graphical_cities.length <= 75 ? true : false

		@actions_by_local = parsed_string[:prevention][:p_local_coalitions_preventive_actions]
		@strategies_by_local = parsed_string[:prevention][:p_local_strategies_to_prevent_hate_to_date]

		render :layout => false
	end

	def show_image
		aws_ip = "54.213.79.234"
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
	    string1 = I18n.t("#{string}")		
		splitted = string1[3..-1].split('_')
		unless splitted[2].nil?
			splitted.delete_at(2)
		end
		return splitted.join('<br />')
	end

	def calculate_graphical_data(incidents, responses)
		graphical_presentation = []

		incidents.each do |i|
			incident_v = i.second
			incident_k = i.first
			response_v = responses[incident_k]
			
			if incident_v.to_i > 0 || response_v.to_i > 0
				graphical_presentation << {:key => incident_k, :incidents => incident_v, :responses => response_v}
			end
		end
		puts "gp cout : #{graphical_presentation.count}"
		return graphical_presentation
	end

	protected

	def set_locale
		I18n.locale = params[:locale] || I18n.default_locale
	end
end