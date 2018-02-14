# frozen_string_literal: true
module V1
  class Privacysettings < Grape::API
    prefix 'api'
    resource :privacysettings do
      params do
        optional :type, type: String
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
        if params[:type].present? && params[:type] == "list"
          {
            status: 200,
            message: '',
            content: Privacysetting.statuses
          }
        else
          pses = ::Privacysetting.where('user_id=? and privacy_type=?', current_user.id,Privacysetting.privacytypes[:wallsetting])
          ps = pses.first unless pses.empty?
          {
            status: 200,
            message: '',
            content: {
                      user_id: current_user.id,
                      privacytype: ps.nil? ? Privacysetting.privacytypes.index(Privacysetting.privacytypes[:wallsetting] ) : ps.privacy_type,
                      status:  ps.nil? ? Privacysetting.statuses[:privacy_public] : Privacysetting.statuses[ps.status.to_s]
                     }
          }
        end
      end

      params do
        requires :status, type: Integer
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
          pses = ::Privacysetting.where('user_id=? and privacy_type=?', current_user.id,Privacysetting.privacytypes[:wallsetting])
          if pses.empty?
            ps = Privacysetting.new(privacy_type: Privacysetting.privacytypes[:wallsetting], user_id: current_user.id, status: params[:status])
            ps.save!
          else
            ps = pses.first
            ps.update(privacy_type: Privacysetting.privacytypes[:wallsetting], user_id: current_user.id, status: params[:status])
          end
          {
            status: 200,
            message: '',
            content: {
                      user_id: current_user.id,
                      privacytype: ps.nil? ? Privacysetting.privacytypes.index(Privacysetting.privacytypes[:wallsetting] ) : ps.privacy_type,
                      status:  Privacysetting.statuses[ps.status.to_s]
                     }
          }
        end
      end
  end
end
