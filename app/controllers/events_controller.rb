class EventsController < ApplicationController

  def index
  end

  def show
  end

  def getCountries
    @reply  = {:status => false, :message => 'Unknown Error', :content => nil}

    countries = File.read("app/assets/data/countries.en.json")
    if countries
      countries = JSON.parse(countries)
      @reply  = {:status => 200, :message => 'countries found', :content => countries}
    else
      @reply  = {:status => 404, :message => 'Data file not found', :content => nil}
    end

    @reply
  end

  def getStates
    @reply  = {:status => false, :message => 'Unknown Error', :content => nil}

    code = params[:code]
    countries = File.read("app/assets/data/countries.en.json")
    if countries
      countries = JSON.parse(countries)
      states = nil
      countries.each do |country|
        if country["code"] == code.upcase
          states = country["states"]
          break
        end
      end

      if states
        @reply  = {:status => 200, :message => 'States found', :content => states}
      else
        @reply  = {:status => 404, :message => 'States not found', :content => nil}
      end
    else
      @reply  = {:status => 406, :message => 'Data file not found', :content => nil}
    end

    @reply
  end

  # private
  #
  #   def event_params
  #     params.require(:event).permit()
  #   end
end
