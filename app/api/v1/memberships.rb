# frozen_string_literal: true
module V1
  class Memberships < Grape::API
    prefix 'api'
    resource :memberships do
      get do
        memberships = MembershipType.where(status: true).order(:billing_frequency, :level)        
        authenticate_user
          if authenticated?
            valid_mem_level = ['employee','instructor','other']
            if current_user.membership_details.present? && (valid_mem_level.include? current_user.membership_details.last.membership_type.level.to_s)
                memberships = MembershipType.where(id: current_user.membership_details.last.membership_type.id)
            end            
          end
        
        {
          status: 200,
          message: '',
          content: Entities::Membership.represent(memberships)
        }
      end

      params do
        requires :membershipTypeId, type: Integer
        requires :user, type: Hash do
          requires :email, allow_blank: false, regexp: /.+@.+/
          requires :firstName, type: String
          requires :lastName, type: String
          requires :telephone, type: String
          requires :password, type: String
          requires :passwordConfirmation, type: String
          requires :currencyId, type: Integer, values: -> { Currency.pluck(:id) }
          # requires :referralId, type: String, allow_blank: true
          # requires :referralCode, type: String, allow_blank: true
        end
        requires :billing, type: Hash do
          requires :street, type: String
          optional :street2, type: String
          requires :city, type: String
          requires :state, type: String
          requires :country, type: String
          requires :zipcode, type: String
        end
        requires :creditcard, type: Hash do
          requires :name, type: String
          requires :number, type: String
          requires :code, type: String
          requires :month, type: String
          requires :year, type: String
        end
      end
      post do
        cc = SubscrptCreditCard.new(number: params[:creditcard][:number],
                                    name: params[:creditcard][:name],
                                    cvs_code: params[:creditcard][:code],
                                    expiry_month: params[:creditcard][:month],
                                    expiry_year: params[:creditcard][:year],
                                    administrative_division: params[:billing][:country])
        user = User.find_by(email: params[:user][:email])
        user = if user.nil?
                 build_user(params[:user])
               else
                 update_user(user, params[:user])
               end
        membership_detail = build_membership(params[:membershipTypeId])
        membership_detail.billing_address = build_address(params[:billing])
        user.membership_details << membership_detail
        user.billing_address = membership_detail.billing_address
        user.role = 'member'
        user.currency = Currency.find(params[:user][:currencyId])
        user.referralId = ''
        user.referralCode = get_referral_id(params[:billing][:referralCode]) #params[:billing][:referralCode].blank? ? 'NONE' : params[:billing][:referralCode]
        user.password_text = params[:user][:password]
        user.entity_id = -1

        if user.save
          pcn_event = ''
          preview_membership = 'T'
          cc.user = user
          cc.save

          item_id = user.membership_details.last.membership_type.item_id.to_s
          nresult = Netsuite::ParelliApi.create_membership(user, item_id, user.billing_address,
                                                           cc, user.referralId,
                                                           pcn_event, preview_membership,
                                                           user.referralCode, user.password_text)
          if nresult.nil?
             membership_detail.destroy!
             cc.destroy!
             user.destroy!

            return {
              status: 404,
              message: "Remote server is not responding. Please try again later!",
              content: nil
            }
          end

          if nresult['returnStatus'] == 'Success'
               nresult_user = Netsuite::NetsuiteApi.authenticate(params[:user][:email], params[:user][:password])
               
               user = User.find_by(email: params[:user][:email])
               Netsuite::ParelliApi.change_credit_card(
                  user.entity_id.to_s,
                  user.subscriptions.last.external_id.to_s,
                  cc
                )

          else
             membership_detail.destroy!
             cc.destroy!
             user.destroy!
          end

          # NetsuiteCreateMemberJob.perform_later(user, user.credit_card, user.password_text, user.referralId, user.referralCode)
        end

        cookies[:user_email] = user.email
        {
          status: nresult['returnStatus'] == 'Success' ? 201 : 404,
          message: nresult['returnMessages'],
          content: user
        }
      end
    end

    helpers do

      def get_referral_id(_referralCode)
        refId = '0'   
        refChar = 'l'    
        if _referralCode.present?
          if _referralCode[0].downcase == 'l'
             refId = Netsuite::NetsuiteApi.getLeadSourceInternalId(_referralCode[1..-1])
          elsif _referralCode[0].downcase == 'p'
             refId = Netsuite::NetsuiteApi.getPartnerInternalId(_referralCode[1..-1])
             refChar = 'p' 
          else
             refId = '0'
          end   
        end     
        (refId.to_s == '0' || refId.to_s == 'NONE') ? 'NONE' : refChar+refId.to_s
      end

      def build_user(user_params)
        user = User.new
        user.first_name = user_params[:firstName]
        user.last_name = user_params[:lastName]
        user.telephone = user_params[:telephone]
        user.email = user_params[:email]
        user.password = user_params[:password]
        user.password = user_params[:passwordConfirmation]
        user
      end

      def build_address(address_params)
        address = Address.new
        address.street = address_params[:street]
        address.street2 = address_params[:street2]
        address.state = address_params[:state]
        address.city = address_params[:city]
        address.country = address_params[:country]
        address.zipcode = address_params[:zipcode]
        address
      end

      def build_membership(id)
        membership_detail = MembershipDetail.new
        membership = MembershipType.find(id)
        membership_detail.membership_type = membership
        membership_detail.billing_frequency = membership.billing_frequency
        membership_detail.tax = membership.tax
        membership_detail.cost = membership.cost
        membership_detail.total = membership.cost
        membership_detail.status = true
        membership_detail.level = membership.level
        membership_detail
      end

      def update_user(user, user_params)
        user.first_name = user_params[:firstName]
        user.last_name = user_params[:lastName]
        user.telephone = user_params[:telephone]
        user.email = user_params[:email]
        user.password = user_params[:password]
        user.password = user_params[:passwordConfirmation]
        user
      end
    end
  end
end
