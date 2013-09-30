class IndexController < ApplicationController
    attr_accessor :search_results
    
    def default
    end

    def s
        if params.include?('words') && !params['words'].empty? 
            @search_results = SController.search(params['words'])
            #render :text => @search_results.inspect
        end

    end
end
