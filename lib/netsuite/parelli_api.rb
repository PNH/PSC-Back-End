# frozen_string_literal: true
module Netsuite
  class ParelliApi
    LOCAL_AUTHENTICATION_SYSTEM	= 'local'.freeze # used by controllers to determine which system to authenticate against
    PNHT_AUTHENTICATION_SYSTEM	= 'pnht'.freeze # used by controllers to determine which system to authenticate against
    NETSUITE_AUTHENTICATION_SYSTEM	= 'netsuite'.freeze # used by controllers to determine which system to authenticate against
    # See https://appcoast.basecamphq.com/projects/4277454/posts/40478130/comments#93242630

    require 'restclient'
    require 'iconv'

    # STAGING_URL_V7		= "http://restdev.parelli.com:8080"
    # STAGING_URL_V7	= 'http://rest-uat.pnh.local'.freeze
    STAGING_URL_V7	= 'https://durango:sun@rest-uat.parelli.com'.freeze
    # STAGING_URL_V7	= 'https://parellisavvyclub-dev2.pnh.local'.freeze
    # STAGING_URL_V7 = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl'.freeze
    PRODUCTION_URL_V7	= 'https://durango:sun@rest.parelli.com'.freeze

    # CREATE A CUSTOMER WITH MEMBERSHIP
    def self.create_membership(_new_member, _item_id, _new_address, _new_card, _referral_id, _pcn_event, _preview_membership, _referral_code, password_text)
      api_result = parelli_api_post('membership/create', email: _new_member.email,
                                                         password: password_text,
                                                         first_name: _new_member.first_name,
                                                         last_name: _new_member.last_name,
                                                         subscription_item_id: _item_id,
                                                         currency_code: _new_member.currency.title,
                                                         addressee: _new_member.first_name + ' ' + _new_member.last_name,
                                                         address1: _new_address.street,
                                                         address2: _new_address.street2,
                                                         city: _new_address.city,
                                                         state: _new_address.state,
                                                         zipcode: _new_address.zipcode,
                                                         country_code: _new_address.country,
                                                         phone_number: _new_member.telephone,
                                                         cc_number: _new_card.number,
                                                         cc_full_name: _new_card.name,
                                                         cc_expiry_month: _new_card.expiry_month,
                                                         cc_expiry_year: _new_card.expiry_year,
                                                         cc_cvs_code: _new_card.cvs_code,
                                                         cc_zipcode: _new_address.zipcode,
                                                         cc_country_code: _new_card.administrative_division,
                                                         pcn_event: _pcn_event,
                                                         referral_id: _referral_id,
                                                         referral_code: _referral_code)
      api_result
    end

    # CHANGE ADDRESS ASSOCIATED WITH MEMBERSHIP
    def self.change_address(_cust_id, _subscription_id, _address_id)
      api_result = parelli_api_put('membership/changeaddress', cust_id: _cust_id,
                                                               subscription_id: _subscription_id,
                                                               address_id: _address_id)
      api_result
    end

    # CREATE AND CHANGE CREDIT CARD ASSOCIATED WITH MEMBERSHIP
    def self.change_credit_card(_cust_id, _subscription_id, _new_card)
      api_result = parelli_api_put('membership/maintaincreditcard', cust_id: _cust_id,
                                                                    subscription_id: _subscription_id,
                                                                    cc_number: _new_card.number,
                                                                    cc_full_name: _new_card.name,
                                                                    cc_expiry_month: _new_card.expiry_month.to_s.rjust(2, '0'),
                                                                    cc_expiry_year: _new_card.expiry_year,
                                                                    cc_cvs_code: _new_card.cvs_code)
      api_result
    end

    # CALCULATE MEMBERSHIP FEE
    def self.calculate_membership_fee(_subscription_id, _item_id)
      api_result = parelli_api_get('membership/' + _subscription_id + '/calculateproration/' + _item_id)
      api_result
    end

    # UPDATE MEMBERSHIP
    def self.change_membership(_cust_id, _subscription_id, _item_id)
      api_result = parelli_api_put('membership/changeitem', cust_id: _cust_id,
                                                            subscription_id: _subscription_id,
                                                            item_id: _item_id)
      api_result
    end

    # CANCEL MEMBERSHIP
    def self.cancel_account(_user, _reason_id, _reason_other)
      api_result = parelli_api_put('membership/cancel', cust_id: _user.entity_id,
                                                        subscription_id: _user.subscriptions.last.external_id,
                                                        cancel_reason_id: _reason_id,
                                                        cancel_reason_other: _reason_other)
      api_result
    end

    # REACTIVATE MEMBERSHIP WITH NEW CREDIT CARD
    def self.reactivate_account(_cust_id, _subscription_id, _new_card, _referral_id, _subscription_item_id)
      api_result = parelli_api_put('membership/reactivate', cust_id: _cust_id,
                                                            subscription_id: _subscription_id,
                                                            subscription_item_id: _subscription_item_id,
                                                            cc_number: _new_card.cc_number,
                                                            cc_full_name: _new_card.cc_name_on_card,
                                                            cc_expiry_month: _new_card.cc_expiry_month.to_s.rjust(2, '0'),
                                                            cc_expiry_year: _new_card.cc_expiry_year,
                                                            cc_cvs_code: _new_card.cc_cvs_code,
                                                            referral_id: _referral_id)
      api_result
    end

    # UPDATE SUBSCRIPTION
    def self.updateSubscription(_subscription_id, _params)
      parelli_api_put('subscription/' + _subscription_id, _params)
    end

    # UPDATE_EMAIL_ADDRESS
    def self.update_email(_cust_id, _email_address)
      api_result = parelli_api_put('customer/' + _cust_id + '/email', email: _email_address)
      api_result
    end

    # UPDATE_PASSWORD
    def self.update_password(_cust_id, _password)
      api_result = parelli_api_put('customer/' + _cust_id + '/password', custentity_pnh_web_password: _password)
      api_result
    end

    # MAINTAIN ADDRESS
    def self.update_address(_cust_id, _new_address)
      label = _new_address.label.nil? ? "Billing Address" : _new_address.label
      api_result = parelli_api_post('customer/' + _cust_id + '/address', label: label,
                                                                         addressbookaddress: {
                                                                           addressee: '',
                                                                           addrphone: '',
                                                                           addr1: _new_address.street,
                                                                           addr2: _new_address.street2,
                                                                           city: _new_address.city,
                                                                           state: _new_address.state,
                                                                           zip: _new_address.zipcode,
                                                                           country: _new_address.country
                                                                         })
      api_result
    end

    # SEND PASSWORD RESET EMAIL
    def self.send_password_reset_email(_email)
      api_result = parelli_api_get('customer/forgotpassword/' + _email)
      api_result
    end

    # REFER A FRIEND
    def self.refer_a_friend(_cust_id, _friend_email, _friend_name)
      api_result = parelli_api_put('membership/referafriend', cust_id: _cust_id,
                                                              recipient_email: _friend_email,
                                                              recipient_name: _friend_name)
      api_result
    end

    # CREATE TEST ACCOUNT
    def self.create_test_account
      username = "new_user_#{Time.current.to_i}.#{Time.current.usec}.#{rand(2_147_483_647)}"
      email = "#{username}@example.com"
      attribs = {
        username: 'unused',
        first_name: 'Test',
        last_name: 'Account',
        test_username: username,
        email: email,
        password: '112233',
        membership_level: 'SAVVY',
        billing_cycle: 'ANNUAL',
        billing_amount: '1',
        currency_code: 'USD',
        cc_full_name: 'Joe Doe',
        cc_number: '4111111111111111',
        cc_expiry_month: '01',
        cc_expiry_year: '2015',
        cc_cvs_code: '123',
        cc_country_code: 'US',
        cc_zipcode: (rand(10_000) + 80_000).to_s,
        cc_administrative_division: 'CA',
        shipping_country_code: 'US',
        shipping_zipcode: (rand(7000) + 90_000).to_s,
        shipping_administrative_division: 'CA',
        shipping_city: 'Cupertino',
        shipping_address1: "#{rand(10_000) + 1} Infinite Loop",
        shipping_phone_number: "#{rand(400) + 400}-#{rand(200) + 600}-#{rand(3000) + 1000}"
      }
      # api_result = parelli_api_post("parelli_create_test_parent_account", attribs)
      savvy_member = SavvyMember.create(user_name: attribs[:test_username],
                                        password_hash: SavvyMember.get_password_hash('112233'),
                                        member_number: '445566',
                                        zipcode: attribs[:shipping_zipcode],
                                        email_address: attribs[:email],
                                        first_name: attribs[:first_name],
                                        last_name: attribs[:last_name],
                                        # :party_id							=> api_result["party_id"],
                                        has_parent: false)
      savvy_member
    end

    def self.get_errors(_api_result)
      errors = {}
      errors[:api_failure] = _api_result['returnMessages'] if _api_result
      errors
    end

    def self.set_object_errors(_object, _api_result)
      _object.errors[:api_failure] = _api_result['returnMessages'] if _api_result
    end

    # PROTECTED
    protected

    def self.parelli_api_get(_method)
      parelli_api_call('GET', _method)
      end

    def self.parelli_api_post(_method, _params)
      parelli_api_call('POST', _method, _params)
      end

    def self.parelli_api_put(_method, _params)
      parelli_api_call('PUT', _method, _params)
      end

    def self.parelli_api_call(_verb, _method, _params = nil)
      end_point = if Rails.env.production?
                    "#{PRODUCTION_URL_V7}/#{_method}"
                  else
                    "#{STAGING_URL_V7}/#{_method}"
                  end
      response = ''
      begin
       response = case _verb
                  when 'GET'  then
                    # RestClient.get end_point, verify_ssl: false
                    RestClient::Request.execute(url: end_point, method: :get, headers: { content_type: 'application/json' }, verify_ssl: false)
                  when 'POST' then
                    RestClient::Request.execute(url: end_point, method: :post, headers: { content_type: 'application/json' }, payload: _params.to_json, verify_ssl: false)
                  when 'PUT'  then
                    # RestClient.put end_point, _params.to_json, content_type: 'application/json', verify_ssl: false
                    RestClient::Request.execute(url: end_point, method: :put, headers: { content_type: 'application/json' }, payload: _params.to_json, verify_ssl: false)
                  end
       if response
         utf_clean = ActiveSupport::Multibyte::Unicode.tidy_bytes(response.body)
         # apilog.store_response(utf_clean, response.code) if apilog

          logger_params = []
          _params.each do |k, v|
            v = k.to_s.include?("cc") || k.to_s.include?("pass") ? '--' : v
            logger_params.push("#{k.to_s}: #{v.to_s}")
          end

         NL_LOGGER.info '-' * 50
         NL_LOGGER.info "#{end_point} #{logger_params.inspect}"
         NL_LOGGER.info '-' * 50
         NL_LOGGER.info "#{response.code} #{utf_clean}"

         if response.code.to_i == 200
           json = ActiveSupport::JSON.decode(utf_clean)
           if Rails.env.development?
             ActiveRecord::Base.logger.info '-' * 50
             ActiveRecord::Base.logger.info "#{end_point} #{_params.inspect}"
             ActiveRecord::Base.logger.info json
             ActiveRecord::Base.logger.info '.' * 50
           end
           return json
         end
       end
     rescue => e
       p e.message
       NL_LOGGER.fatal e.message
       notify_parelli(end_point, _params)
     end
      nil
      end

    def self.notify_parelli(_end_point, _params)
      # _params[:password]	= '[FILTERED]'
      # _params[:cc_number]	= '[FILTERED]'
      # _params[:cc_expiry_year]	= '[FILTERED]'
      # _params[:cc_full_name]	= '[FILTERED]'
      # _params[:cc_cvs_code]	= '[FILTERED]'
      # _params[:cc_zipcode]	= '[FILTERED]'
      url = _end_point.gsub(/\Ahttps:\/\/\S+:\S+@/, 'https://[FILTERED]:[FILTERED]@')
      error = ['Error: Unable to communicate with the API']
      error << "Reason: #{$ERROR_INFO}"
      error << "End point: #{url}"
      error << "Parameters: #{_params.inspect}"
      error << "Time: #{Time.current}"
      error << $ERROR_POSITION
      # Mailer.api_error_to_parelli(error.join("\n\n")).deliver
      NL_LOGGER.fatal error.join("\n\n")
    end
  end
end
