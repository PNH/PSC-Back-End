# frozen_string_literal: true
module V1
  class Users < Grape::API
    prefix 'api'
    resource :users do
    end

    namespace 'users/profile' do
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        {
          status: 200,
          message: '',
          content: {
            user: Entities::Profile.represent(current_user),
            membership: Entities::MembershipDetail.represent(current_user.membership_details.last),
            creditcard: Entities::CreditCard.represent(SubscrptCreditCard.new)
            # creditcard: current_user.subscriptions.last.subscrpt_credit_card.nil? ? Entities::CreditCard.represent(SubscrptCreditCard.new) : Entities::CreditCard.represent(current_user.subscriptions.last.subscrpt_credit_card)
          }
        }
      end

      params do
        requires :user, type: Hash do
          requires :firstName, type: String
          requires :lastName, type: String
          optional :birthday, type: String
          requires :music, type: String
          requires :books, type: String
          requires :website, type: String
          requires :bio, type: String
          requires :gender, type: Integer
          requires :relationship, type: Integer, values: User.relationships.values, allow_blank: true
          requires :equestrainStyle, type: Integer, values: User.equestrain_styles.values, allow_blank: true
          # requires :equestrainInterest, type: Integer, values: User.equestrain_interests.values, allow_blank: true
          requires :equestrainInterest, type: JSON do
            requires :id, type: Integer
          end
          requires :level, type: Integer, values: Level.pluck(:id), allow_blank: true
          optional :humanity, type: Integer, values: User.humanities.values, allow_blank: true
          # optional :file, type: Rack::Multipart::UploadedFile
          optional :profile_picture, type: String
          optional :currencyId, type: Integer, values: -> { Currency.pluck(:id) }
          requires :homeAddress, type: Hash do
            requires :street, type: String
            optional :street2, type: String
            requires :city, type: String
            requires :state, type: String
            requires :country, type: String
            requires :zipcode, type: String
            requires :xCoordinate, type: String
            requires :yCoordinate, type: String
          end
          requires :billingAddress, type: Hash do
            requires :street, type: String
            optional :street2, type: String
            requires :city, type: String
            requires :state, type: String
            requires :country, type: String
            requires :zipcode, type: String
            requires :xCoordinate, type: String
            requires :yCoordinate, type: String
          end
          optional :instructors, type: JSON do
            requires :id, type: Integer
          end
        end
        requires :creditcard, type: Hash do
          requires :id, type: Integer, allow_blank: true
          requires :name, type: String
          requires :number, type: String
          requires :cvs_code, type: String
          requires :expiry_month, type: String
          requires :expiry_year, type: String
        end
        optional :membershipTypeId, type: Integer, allow_blank: true
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        update_user(params[:user])

        profile_picture_file = ApiHelper.decode_base64_image(params[:user][:profile_picture])
        update_user_profile_pic(profile_picture_file) unless profile_picture_file.blank?

        if params[:update].present? && params[:update] == "membership"
          nscc_result = update_credit_card(params[:creditcard])
          nsmem_result = update_membership(params[:membership][:membershipTypeId]) unless params[:membership][:membershipTypeId].blank?
          nsadd_result = update_address(params[:user][:billingAddress]) unless params[:user][:billingAddress].blank?
        end

        if nscc_result.present?  && nscc_result['returnStatus'] == "Error"
          {
            status: 404,
            message: "Credit Card : "+nscc_result['returnMessages'][0]['errorMessage'],
            content: false
          }
        elsif nsmem_result.present? && nsmem_result['returnStatus'] == "Error"
          {
            status: 404,
            message: "Membership : "+nsmem_result['returnMessages'][0]['errorMessage'],
            content: false
          }
        elsif nsadd_result.present? && nsadd_result['returnStatus'] == "Error"
          {
            status: 404,
            message: "Billing Address : "+nsadd_result['returnMessages'][0]['errorMessage'],
            content: false
          }
        else
          {
            status: 200,
            message: 'success',
            content: true
          }
        end



      end
    end

    namespace 'users/:id/profile' do
      params do
        requires :id
      end
      get do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end
        user = User.find_by_id(params[:id])
        if user.present?
        {
          status: 200,
          message: '',
          content: {
            user: Entities::ProfileSummary.represent(user, current_user: current_user),
          }
        }
        else
          {
            status: 404,
            message: 'User not found',
            content: ''
          }
        end
      end
    end

    namespace 'users/update_email' do
      params do
        requires :email, :password
      end
      post do
        authenticate_user
        unless authenticated?
          return {
            status: 401,
            message: 'Unauthorized',
            content: ''
          }
        end

        result = Netsuite::NetsuiteApi.authenticate(params[:email], params[:password])
        message = ''

        unless result[:status] == 1
          case result[:status]
          when -1
            message = "Sorry, but it appears that your membership has become inactive! Maybe you moved or got a new credit card? Either way, we're here to help; please contact your local office as soon as possible and we'll help you reactivate."
          when 0
            message = "Your current password is invalid"
          end
          return {
                status: 404,
                message: message,
                content: ''
             }
        end

        if User.where('users.email = ?', params[:email].downcase).first
            return {
              status: 404,
              message: 'Email Aleady Exists',
              content: ''
            }
        end

        nsresult = update_email(params)

        if nsresult.present?  && nsresult['returnStatus'] == "Success"
          current_user.email = params[:email]
          current_user.save!
          return {
            status: 200,
            message: '',
            content: {
              user: Entities::Profile.represent(current_user),
            }
          }
        else
          return {
            status: 404,
            message: nsresult['returnMessages'][0]['errorMessage'],
            content: false
          }
        end
      end
    end

    namespace 'users/exist' do
      params do
        requires :email, allow_blank: false, regexp: /.+@.+/
      end
      get do
        {
          status: 200,
          message: '',
          content: {
            exist: User.where(role: User.roles.values_at(:admin, :super_admin, :member)).exists?(email: params[:email])
          }
        }
      end
    end

    namespace 'users/meta' do
      params do
      end
      get do
        content = {
          "ridingStyle": User.equestrain_styles,
          "equestrainInterest": UserEquestrainInterest.equestrain_interest_list,
          "relationshipTypes": User.relationships,
          "humanities": User.humanities,
          "genders": User.genders
        }
        response = { status: 200, message: 'User profile meta data', content: content }
        return response
      end
      # resource :riding_styles do
      #   get do
      #     {
      #       status: 200,
      #       message: '',
      #       content: User.equestrain_styles
      #     }
      #   end
      # end
      #
      # resource :equestrain_interest do
      #   get do
      #     {
      #       status: 200,
      #       message: '',
      #       content: User.equestrain_interests
      #     }
      #   end
      # end
      #
      # resource :relationship do
      #   get do
      #     {
      #       status: 200,
      #       message: '',
      #       content: User.relationships
      #     }
      #   end
      # end
    end

    namespace 'user/membership/cancel/reasons' do
      get do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          response = { status: 200, message: 'Reason List', content: MembershipCancellation.reasons }
        end

        return response
      end
    end

    namespace 'user/membership/cancel' do
      # params do
      #   requires :confirm, type: Boolean
      # end
      # get do
      #   response = { status: 401, message: 'Unauthorized', content: nil }
      #   authenticate_user
      #   if authenticated?
      #     user = User.find_by id: current_user.id
      #     result = cancel_membership(user, -1, nil)
      #     if result
      #       user.role = User.roles[:deleted]
      #       if user.save!
      #         response = { status: 200, message: 'Account deactivated', content: params[:confirm] }
      #       else
      #         response = { status: 500, message: 'Failed to deactivate profile', content: params[:confirm] }
      #       end
      #     else
      #       response = { status: 500, message: 'Netsuite error', content: result }
      #     end
      #   end
      #
      #   return response
      # end
      params do
        requires :confirm, type: Boolean
        requires :reason, type: Integer, values: MembershipCancellation.reasons.values
        optional :note, type: String
      end
      post do
        response = { status: 401, message: 'Unauthorized', content: nil }
        authenticate_user
        if authenticated?
          user = User.find_by id: current_user.id
          # user = User.find_by id: 624
          result = cancel_membership(user, params[:reason], params[:note])
          if !result.nil? && result["returnStatus"]=="Success"
            user.role = User.roles[:deleted]
            cancelnote = ::MembershipCancellation.new(user_id: user.id, reason: params[:reason], note: params[:note])
            if cancelnote.save!
              if user.save!
                response = { status: 200, message: 'Account deactivated', content: params[:confirm] }
              else
                response = { status: 500, message: 'Failed to deactivate profile', content: params[:confirm] }
              end
            else
              response = { status: 500, message: 'Failed to save the reason', content: false }
            end

          else
            response = { status: 500, message: 'Netsuite error', content: result }
          end
        end

        return response
      end
    end

    helpers do

      def update_email(params)
        if current_user.email != params[:email].to_s
            nsresult = Netsuite::ParelliApi.update_email(current_user.subscriptions.last.external_id.to_s, params[:email])
        end
        nsresult
      end

      def update_user_profile_pic(file_attrs)
        profile_img = Rich::RichFile.new(simplified_type: 'image')
        file_params = Rack::Multipart::UploadedFile.new file_attrs[:tempfile].path, file_attrs[:type]
        profile_img.rich_file = file_params
        profile_img.rich_file_file_name = file_attrs[:filename]
        current_user.profile_picture = profile_img
        current_user.save!
      end

      def build_address(address_param)
        address = Address.new
        address.street = address_param[:street]
        address.street2 = address_param[:street2]
        address.state = address_param[:state]
        address.city = address_param[:city]
        address.country = address_param[:country]
        address.zipcode = address_param[:zipcode]
        address.latitude = address_param[:xCoordinate]
        address.longitude = address_param[:yCoordinate]
        address
      end

      def update_address(address_param)

       if(current_user.billing_address.street != address_param[:street] ||
         current_user.billing_address.street2 != address_param[:street2] ||
         current_user.billing_address.city != address_param[:city] ||
         current_user.billing_address.state != address_param[:state] ||
         current_user.billing_address.zipcode != address_param[:zipcode] ||
         current_user.billing_address.country != address_param[:country] )

         address = Address.new
         address.street = address_param[:street]
         address.street2 = address_param[:street2]
         address.state = address_param[:state]
         address.city = address_param[:city]
         address.country = address_param[:country]
         address.zipcode = address_param[:zipcode]

         nsresult = Netsuite::ParelliApi.update_address(current_user.entity_id.to_s, address)

         if nsresult['returnStatus'] == "Success"
           maxid = nsresult['returnPayload']['addressbook'].max_by{|e| e['id']}
           nsresult = Netsuite::ParelliApi.change_address(current_user.entity_id.to_s, current_user.subscriptions.last.external_id, maxid['id'])
           if nsresult['returnStatus'] == "Success"
             address.ns_id = maxid['id']
             current_user.billing_address = address
             current_user.save!
           end
         end
         nsresult
       end

      end

      def update_user(user_params)

        if current_user.email != user_params[:email]
          Netsuite::ParelliApi.update_email(current_user.subscriptions.last.external_id.to_s, user_params[:email])
        end

        user = User.find_by id: current_user.id

        user.first_name = user_params[:firstName]
        user.last_name = user_params[:lastName]
        user.birthday = DateTime.strptime(user_params[:birthday], '%m/%d/%Y') unless user_params[:birthday].blank?
        user.music = user_params[:music]
        user.books = user_params[:books]
        user.website = user_params[:website]
        user.bio = user_params[:bio]
        user.gender = user_params[:gender]
        user.relationship = User.relationships.keys[user_params[:relationship]] unless user_params[:relationship].blank?
        user.equestrain_style = User.equestrain_styles.keys[user_params[:equestrainStyle]] unless user_params[:equestrainStyle].blank?
        # user.equestrain_interest = User.equestrain_interests.keys[user_params[:equestrainInterest]] unless user_params[:equestrainInterest].blank?
        user.level = Level.find(user_params[:level]) unless user_params[:level].blank?
        user.home_address = build_address(user_params[:homeAddress])
        user.humanity = user_params[:humanity]

        if !user.user_equestrain_interests.nil?
          user.user_equestrain_interests.delete_all
        else
          user.user_equestrain_interests = []
        end
        user_params[:equestrainInterest].each do |interest|
          obj = UserEquestrainInterest.new(user_id: user.id, equestrain_interest_id: interest.id)
          user.user_equestrain_interests << obj
        end

        if !user.instructors.nil?
          user.instructors.delete_all
        else
          user.instructors = []
        end
        if !user_params[:instructors].nil?
          user_params[:instructors].each do |instructor|
            obj = UserInstructor.new(user_id: user.id, instructor_id: instructor.id)
            user.instructors << obj
          end
        end
        # user.billing_address = build_address(user_params[:billingAddress])
        user.save!

      end

      def update_membership(membershipTypeId)
        membership_detail = build_membership(membershipTypeId)
        membership_detail.billing_address = current_user.billing_address
        current_user.membership_details << membership_detail
        current_user.save!

        subscription = membership_detail.user.subscriptions.last
        nsresult =Netsuite::ParelliApi.change_membership(current_user.entity_id.to_s, subscription.external_id, membership_detail.membership_type.item_id)
        nsresult
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

      def update_credit_card(cards_params)
        # NetsuiteChangeCreditCardJob.perform_later(current_user.id, cards_params)

        if(cards_params[:name].present? &&
           cards_params[:number].present? &&
           cards_params[:expiry_month].present? &&
           cards_params[:expiry_year].present? &&
           cards_params[:cvs_code].present? )

          card = SubscrptCreditCard.new
          card.name = cards_params[:name]
          card.number = cards_params[:number]
          card.expiry_month =  cards_params[:expiry_month]
          card.expiry_year = cards_params[:expiry_year]
          card.cvs_code = cards_params[:cvs_code]


          nsresult = Netsuite::ParelliApi.change_credit_card(
            current_user.entity_id.to_s,
            current_user.subscriptions.last.external_id.to_s,
            card
          )
        end
        nsresult
      end

      def cancel_membership(user, reason_id, note)
        response = Netsuite::ParelliApi.cancel_account(user, reason_id, note)
        return response
      end

    end
  end
end
