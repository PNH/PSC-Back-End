# frozen_string_literal: true
module V1
  module Entities
    class CreditCard < Grape::Entity
      expose :id, :name, :number, :cc_type, :expire_date, :expiry_month, :expiry_year, :cvs_code
    end
  end
end
