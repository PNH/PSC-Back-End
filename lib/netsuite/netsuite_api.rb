# frozen_string_literal: true
module Netsuite
  class NetsuiteApi
    require 'restclient'
    require 'iconv'
    NETSUITE_URL = 'https://rest.netsuite.com/app/site/hosting/restlet.nl'.freeze
    NETSUITE_SANDBOX_URL = 'https://rest.sandbox.netsuite.com/app/site/hosting/restlet.nl'.freeze
    NETSUITE_BETA_URL =  'https://rest.na1.beta.netsuite.com/app/site/hosting/restlet.nl'.freeze
    NETSUITE_SYSTEM = 'SANDBOX'.freeze

    # VISA=5
    # DISCOVER=3
    # MC=4
    # AMEX=6

    # AUTHENTICATE
    def self.authenticate(_email, _password)
      api_result = call_ns_api('GET', field: _email, pass: _password, script: 'customscript47', deploy: 1, system: 'CONNECT')
      # p api_result      
      parseApiResult(api_result)
    end

    # UPDATE SUBSCRIPTION ADDRESS
    def self.updateSubscriptionAddress(_subscriptionId, _memberId, _address)
      if _address.addr1.nil? || _address.addr1 == ''
        api_result = call_ns_api('GET',                                  subscriptionid: _subscriptionId,
                                                                         custid: _memberId,
                                                                         addressid: _address.ns_id,
                                                                         script: 'customscript177',
                                                                         deploy: 1,
                                                                         system: 'CONNECT')
      else
        api_result = call_ns_api('GET',                                  subscriptionid: _subscriptionId,
                                                                         custid: _memberId,
                                                                         addressid: _address.ns_id,
                                                                         addr1: _address.addr1,
                                                                         addr2: _address.addr2,
                                                                         city: _address.city,
                                                                         state: _address.state,
                                                                         zip: _address.zip,
                                                                         country: _address.country_code,
                                                                         addressee: _address.addressee,
                                                                         #:attention => _address,
                                                                         defaultshipping: 'F',
                                                                         defaultbilling: 'F',
                                                                         isresidential: 'F',
                                                                         override: 'F',
                                                                         script: 'customscript177',
                                                                         deploy: 1,
                                                                         system: 'CONNECT')
      end
    end

    # UPDATE SUBSCRIPTION CREDITCARD
    def self.updateSubscriptionCreditCard(_subscriptionId, _memberId, _creditcard)
      if _creditcard.cc_number.nil? || _creditcard.cc_number == ''
        api_result = call_ns_api('GET',                                  subscriptionid: _subscriptionId,
                                                                         custid: _memberId,
                                                                         ccid: _address.ns_id,
                                                                         script: 'customscript177',
                                                                         deploy: 1,
                                                                         system: 'CONNECT')
      else
        api_result = call_ns_api('GET',                                  subscriptionid: _subscriptionId,
                                                                         custid: _memberId,
                                                                         ccid: _creditcard.ns_id,
                                                                         ccnumber: _creditcard.cc_number,
                                                                         ccname: _creditcard.cc_name,
                                                                         ccexpiredate: _creditcard.cc_expire_date,
                                                                         ccdefault: 'F',
                                                                         script: 'customscript178',
                                                                         deploy: 1,
                                                                         system: 'CONNECT')
      end
    end

    # Retrieve Partner internalid from Partner Code
    def self.getPartnerInternalId(_partnerCode)
      api_result = call_ns_api('GET', id: _partnerCode,
                                      script: 'customscript160',
                                      deploy: 1,
                                      system: 'CONNECT')
      # Returns the internalid of the Partner
      if api_result['Error']
        return '0'
      else
        return api_result['id']
      end
    end

    # Retrieve Lead Source internalid from Campaign Code (Lead Source)
    # NOTE: This call only retrieves the internalid and not the entire record
    def self.getLeadSourceInternalId(_campaignCode)
      api_result = call_ns_api('GET', id: _campaignCode,
                                      script: 'customscript_pnh_lsfromcampid',
                                      deploy: 1,
                                      system: 'CONNECT')
      # Returns the internalid of the Campaign
      if api_result['Error']
        return '0'
      else
        return api_result['id']
      end
      end

    # Record PCN Login on Subscription record providing customer internalid
    def self.recordPCNLogin(_customerid)
      api_result = call_ns_api('GET', id: _customerid,
                                      script: 'customscript_pnh_record_pcn_login',
                                      deploy: 1,
                                      system: 'CONNECT')
      end

    # PROTECTED

    protected

    def self.parseApiResult(api_result)
      # _member = Member.new
      # puts JSON.pretty_generate(api_result)
      if api_result && api_result['pnh_subscriptions']
        al = false
        api_result['pnh_subscriptions'].each do |s|

          # al = true if s['custrecord_pnh_subscrpt_pcn_access'] && s['custrecord_pnh_subscrpt_pcn_access'] == 'T'
          #temporally fix , This should be a pcn at the end
          al = true if s['custrecord_pnh_subscrpt_psc_access'] && s['custrecord_pnh_subscrpt_psc_access'] == 'T' && s['isinactive'] == 'F'
        end
        unless al
          NL_LOGGER.fatal "#{api_result} Access Denied"
          return {status: -1, content: nil}
        end
      end
      if api_result && api_result['Error']
        NL_LOGGER.fatal api_result['Error']
        return {status: 0, content: nil}
      elsif api_result
        customer = api_result['customer']
        partner = api_result['partner']
        subscrpts = api_result['pnh_subscriptions']
        parentFlag = api_result['childaccess'] == 'F' ? true : false
        childFlag = api_result['childaccess'] == 'T' ? true : false
        currencies = customer['currency']
        addresses = customer['addressbook']
        creditcards = customer['creditcards']
        # found_member = User.where('users.entity_id = ?', customer['id'].to_i).first
        found_member = User.where('users.email = ?', customer['email'].downcase).first
        instr_star = 0
        instr_active = false
        instr_junior = false
        emply_active = customer['custentity_pnh_employee_record'] && customer['custentity_pnh_employee_record'] != '' ? true : false
        if
            partner &&
            partner['custentity_pnh_instructor_license_status'] &&
            partner['custentity_pnh_instructor_license_status']['name'] == 'Licensed'

          instr_active = true
          instr_star_date = nil
          if partner['recmachcustrecord_pnh_starrating_instructor']
            for star in partner['recmachcustrecord_pnh_starrating_instructor']
              next unless star['custrecord_pnh_starrating_type']['name'] == 'INSTRUCTOR' || star['custrecord_pnh_starrating_type']['name'] == 'JUNIOR INSTRUCTOR'
              begin
                temp_star_date = Date.strptime(star['custrecord_pnh_starrating_date'], '%m/%d/%Y')
              rescue
                temp_star_date = Date.today
              end
              next unless !instr_star_date || temp_star_date > instr_star_date
              instr_star = star['custrecord_pnh_starrating_level']['name'].to_i
              instr_star_date = temp_star_date
              instr_junior = star['custrecord_pnh_starrating_type']['name'] == 'JUNIOR INSTRUCTOR'
            end
          end
        end

        # p emply_active
        # p instr_active
        # p instr_star
        if found_member
          found_member.update_attributes(email: customer['email'].downcase,
                                         entity_id: customer['id'],
                                         username: customer['custentity_pnh_user_name'],
                                         #  password_hash: ToolSet.create_sha_512_hash(customer['custentity_pnh_web_password'], found_member.salt),
                                         last_sign_in_at: DateTime.now, # Date.today
                                         nr_instructor_stars: instr_star,
                                         is_instructor: instr_active,
                                         is_instructor_junior: instr_junior,
                                         is_staff_member: emply_active,
                                         is_parent: parentFlag,
                                         is_child: childFlag,
                                         good_standing: true,
                                         is_disabled: false,
                                         role: 'member'
                                         )
          upsertAddresses(found_member, addresses)
          upsertSubscrptCreditCard(found_member, creditcards)
          upsertSubscriptions(found_member, customer['entityid'], subscrpts, currencies)
          # found_member.set_geo_location unless found_member.updated_coords? && found_member.location_set?
          return {status: 1, content: found_member}
        else
          if customer['companyname']
            first_name = last_name = customer['companyname'].capitalize
          end
          first_name = customer['firstname'].capitalize if customer['firstname']
          last_name = customer['lastname'].capitalize if customer['lastname']
          params = {
            username: customer['custentity_pnh_user_name'],
            legacy_party_id: customer['custentitycust_party_id'],
            entity_id: customer['id'],
            email: customer['email'].downcase,
            password: customer['custentity_pnh_web_password'],
            #:password => ToolSet::create_sha_512_hash(customer["custentitycust_web_pass"], self.salt),
            first_name: first_name,
            last_name: last_name,
            last_sign_in_at: DateTime.now, # Date.today
            nr_instructor_stars: instr_star,
            is_instructor: instr_active,
            is_staff_member: emply_active,
            is_parent: parentFlag,
            is_child: childFlag,
            good_standing: true,
            role: 'member'
          }
          found_member = User.create(params)
          # if found_member.errors.empty?
          upsertAddresses(found_member, addresses)
          upsertSubscrptCreditCard(found_member, creditcards)
          upsertSubscriptions(found_member, customer['entityid'], subscrpts, currencies)
          # found_member.set_geo_location
          return {status: 1, content: found_member}
        end
      end
      return {status: 0, content: nil}
    end

    def self.upsertSubscrptCreditCard(_member, _creditcards)
      SubscrptCreditCard.destroy_all(user_id: _member.id)
      if _creditcards
        for cc in _creditcards
          creditcard = SubscrptCreditCard.create(user: _member,
                                                   ns_id: cc['internalid'].to_i,
                                                   default: cc['ccdefault'],
                                                   name: cc['ccname'],
                                                   number: cc['ccnumber'].to_s,
                                                   cc_type: cc['paymentmethod']['name'],
                                                   expire_date: DateTime.parse(cc['ccexpiredate']))


        end
      end
    end

    def self.upsertAddresses(_member, _addresses)
      # Address.destroy_all(member_id: _member.id)
      if _addresses
        for address in _addresses
          next unless address['addressbookaddress']
          add = Address.find_by_ns_id(address['id'])
          if add
            add.update_attributes(
              street: address['addressbookaddress']['addr1'],
              street2: address['addressbookaddress']['addr2'],
              city: address['addressbookaddress']['city'],
              state: address['addressbookaddress']['state'],
              # display_state: address['addressbookaddress']['state'],
              zipcode: address['addressbookaddress']['zip'],
              country: address['addressbookaddress']['country']['internalid'],
              # display_country: address['addressbookaddress']['country']['name'],
              # addressee: address['addressbookaddress']['addressee'],
              addrtext: address['addressbookaddress']['addrtext'],
              label: address['label']
            )
          # default_billing: address['defaultbilling'],
          # default_shipping: address['defaultshipping'],
          # shipping_country_id: ShippingCountry.find_by_country_code(address['addressbookaddress']['country']['internalid'])
          else
            add = Address.create(
              ns_id: address['id'],
              street: address['addressbookaddress']['addr1'],
              street2: address['addressbookaddress']['addr2'],
              city: address['addressbookaddress']['city'],
              state: address['addressbookaddress']['state'],
              # display_state: address['addressbookaddress']['state'],
              zipcode: address['addressbookaddress']['zip'],
              country: address['addressbookaddress']['country']['internalid'],
              # display_country: address['addressbookaddress']['country']['name'],
              # addressee: address['addressbookaddress']['addressee'],  
              addrtext: address['addressbookaddress']['addrtext'],
              label: address['label']
            )
            #  default_billing: address['defaultbilling'],
            #  default_shipping: address['defaultshipping'],
            #  shipping_country_id: ShippingCountry.find_by_country_code(address['addressbookaddress']['country']['internalid'])
          end
          
        end
        # maxid = _addresses.max_by{|e| e['id']}
        # lastest_addr = Address.where('ns_id = ?', maxid['id'].to_s)

        # if lastest_addr.present?
        #   _member.billing_address = lastest_addr
        #   _member.save!         
        #   # _member.home_address = add if address['isresidential']
        # end
      end
    end

    def self.getCurrencyCode(_currencyId, currencies)
      currency_code = 'USD'
      if currencies && currencies.size.positive?
        for currency in currencies
           if currency['currency']['internalid'].to_i == _currencyId.to_i
             currency_code = currency['currency']['name']
           end
        end
      end
      currency_code
    end

    def self.upsertSubscriptions(_member, _entityId, subscrpts, _currencies)
      Subscription.destroy_all(user_id: _member.id)
      has_subscriptions = false
      if subscrpts && subscrpts.size.positive?

        for subscrpt in subscrpts

          next unless subscrpt['isinactive'] == 'F'
          sDate  = subscrpt['custrecord_pnh_subscrpt_start_date'].blank?    ? nil : Date.strptime(subscrpt['custrecord_pnh_subscrpt_start_date'], '%m/%d/%Y')
          eDate  = subscrpt['custrecord_pnh_subscrpt_end_date'].blank?      ? nil : Date.strptime(subscrpt['custrecord_pnh_subscrpt_end_date'], '%m/%d/%Y')
          cDate  = subscrpt['custrecord_pnh_inactive_date'].blank?          ? nil : Date.strptime(subscrpt['custrecord_pnh_inactive_date'], '%m/%d/%Y')
          sub = Subscription.create(user: _member,
                                    currency: subscrpt['custrecord_pnh_subscrpt_currency']['internalid'],
                                    address: Address.find_by_ns_id(subscrpt['custrecord_pnh_subscrpt_address']['id']),
                                    subscrpt_credit_card: SubscrptCreditCard.find_by_ns_id(subscrpt['custrecord_pnh_subscrpt_cc_id']),
                                    is_parent: true, # subscrpt["reference],
                                    entity_id: _entityId,
                                    external_id: subscrpt['id'],
                                    display_id: subscrpt['name'],
                                    price: subscrpt['custrecord_pnh_subscrpt_price'],
                                    membership_level: subscrpt['membershiplevel'],
                                    membership_cycle: subscrpt['membershipcycle'],
                                    start_date: sDate,
                                    end_date: eDate,
                                    is_auto_renewal: subscrpt['custrecord_pnh_subscrpt_auto_renewal'] == 'T' ? true : false,
                                    is_active: subscrpt['isinactive'] == 'F' ? true : false,
                                    is_lifetime: subscrpt['custrecord_pnh_subscrpt_lifetime'] == 'T' ? true : false,
                                    is_promotion: subscrpt['custrecord_pnh_subscrpt_promotion'] == 'T' ? true : false,
                                    product: subscrpt['custrecord_pnh_subscrpt_item']['internalid'],
                                    charge_status: subscrpt['custrecord_pnh_subscrpt_charge_status']['internalid'],
                                    inactive_date: cDate,
                                    inactive_reason: subscrpt['custrecord_pnh_inactive_reason']['name'])
          has_subscriptions = true

        end
        updateMembershipType(_member, _currencies)
      end



      # _member.update_attributes(good_standing: _member.is_active?,
      #                           had_membership: has_subscriptions,
      #                           legacy_membership_level: _member.get_highest_membership)
    end

    def self.updateMembershipType(_member, _currencies)

      subscription_list = _member.subscriptions.where(is_active: true).order(start_date: :desc)
      if subscription_list.count > 0
        subscription = subscription_list.first
        MembershipDetail.destroy_all(user_id: _member.id)        
        mtype = MembershipType.find_by_item_id(subscription.product)
        mtype = mtype.nil? ? MembershipType.find_by_item_id(1000) : mtype 
        currency_code = getCurrencyCode(subscription.currency.to_i, _currencies)

        _member.currency = Currency.find_by_title(currency_code.nil? ? 'USD' : currency_code)
        _member.billing_address = Address.find_by_ns_id(subscription.address.ns_id)
        _member.save!

        membership_detail = MembershipDetail.new
        membership_detail.membership_type = mtype
        membership_detail.billing_frequency = mtype.billing_frequency
        membership_detail.tax = mtype.tax
        membership_detail.cost = subscription.price
        membership_detail.total =subscription.price
        membership_detail.status = true
        membership_detail.level = mtype.nil? ? subscription.membership_level : mtype.level
        membership_detail.user = _member
        membership_detail.save!

      end

    end

    def self.fetchWebActivities
      # customscript_pnh_fetch_web_activites
      time = Time.new
      api_result = call_ns_api('GET', script: 'customscript_pnh_fetch_web_activites', deploy: 1, from_date: "#{time.month}/#{time.day}/#{time.year}")
      api_result
    end

    def self.call_ns_api(_method, _params)
      end_point           =   NETSUITE_SANDBOX_URL.to_s
      nlauth_account      =   '3410633'
      nlauth_email        =   'it787dontuse@parelli.com'
      nlauth_signature    =   '!24TY987uI7Z'
      nlauth_role         = '1027'
      end_point = NETSUITE_BETA_URL if NETSUITE_SYSTEM == 'BETA'
      end_point = NETSUITE_URL.to_s if Rails.env.production?
      nlauth_string = 'NLAuth nlauth_account=' + nlauth_account + ',nlauth_email=' + nlauth_email + ',nlauth_signature=' + nlauth_signature + ',nlauth_role=' + nlauth_role
      response = ''

      begin
        # unless Rails.env.production?
        apilog = nil # Apilog.store_request(end_point, _params.inspect)
        # end
        if _method == 'POST'
          response = RestClient.post(end_point, params: _params, content_type: 'application/json', accept: :json, authorization: nlauth_string)
        elsif _method == 'PUT'
          response = RestClient.put(end_point, params: _params, content_type: 'application/json', authorization: nlauth_string)
        elsif _method == 'DELETE'
          response = RestClient.delete(end_point, params: _params, content_type: 'application/json', authorization: nlauth_string)
        else
          # else do get by default
          response = RestClient.get(end_point, params: _params, content_type: 'application/json', authorization: nlauth_string)
        end
        if response
          utf_clean = ActiveSupport::Multibyte::Unicode.tidy_bytes(response.body)
          # unless Rails.env.production?
          
          logger_params = []
          _params.each do |k, v|           
            v = k.to_s.include?("pass") ? '--' : v
            logger_params.push("#{k.to_s}: #{v.to_s}")
          end

          NL_LOGGER.info '-' * 50
          NL_LOGGER.info "#{end_point} [#{logger_params.inspect}]"
          NL_LOGGER.info "#{response.code} #{utf_clean}"
          # end
          if response.code.to_i == 200
            json = ActiveSupport::JSON.decode(utf_clean)
            if Rails.env.development?
              # displays api call request and response in DEV ONLY in server logs
              # ActiveRecord::Base.logger.info "-"*50
              # ActiveRecord::Base.logger.info "#{end_point} #{_params.inspect}"
              # ActiveRecord::Base.logger.info json
              # ActiveRecord::Base.logger.info "-"*50
            end
            return json
          end
        end
      rescue Exception => e
        p e
        p 'OUCH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        notify_parelli(end_point, _params)
      end
      nil
    end

    def self.notify_parelli(_end_point, _params)
      # _params[:password]       = '[FILTERED]'
      # _params[:pass]           = '[FILTERED]'
      # _params[:cc_number]      = '[FILTERED]'
      # _params[:cc_expiry_year] = '[FILTERED]'
      # _params[:cc_full_name]   = '[FILTERED]'
      # _params[:cc_cvs_code]    = '[FILTERED]'
      # _params[:cc_zipcode]     = '[FILTERED]'
      url = _end_point.gsub(/\Ahttps:\/\/\S+:\S+@/, 'https://[FILTERED]:[FILTERED]@')
      error = ['Error: Unable to communicate with the API']
      error << "Reason: #{$ERROR_INFO}"
      error << "End point: #{url}"
      error << "Parameters: #{_params.inspect}"
      error << "Time: #{Time.current}"
      error << $ERROR_POSITION
      # Mailer.api_error_to_parelli(error.join("\n\n")).deliver
    end

    def self.result_contains_error(_result, _error_code)
      _result['errors'].each { |error| return true if error['code'].to_i == _error_code.to_i }
      false
    end
  end
end
