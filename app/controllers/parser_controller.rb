class ParserController < ApplicationController
	def parse
		@string = params[:csv]
	end

	def rasterize
		`./vendor/plugins/phantomjs/bin/phantomjs vendor/plugins/phantomjs/bin/rasterize.js http://localhost:3000/parse?csv=a_s_d_f public/inphographics/test.png`
	end
end