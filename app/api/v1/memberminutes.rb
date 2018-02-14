# frozen_string_literal: true
module V1
  class Memberminutes < Grape::API
    prefix 'api'
    resource :member_minutes do
    end
    prefix 'api'
    namespace 'memberminutes' do
      params do
        requires :page, type: Integer
        requires :limit, type: Integer
        optional :year, type: Integer
        optional :month, type: Integer
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
          mm = nil
        unless params[:year].nil? || params[:month].nil?
          mm = ::MemberMinute.where('extract(year  from publish_date) = ? AND extract(month  from publish_date) = ? AND featured = false AND status=true', params[:year], params[:month]).order(publish_date: :desc, id: :asc).page(params[:page]).per(params[:limit])
        else
          mm = ::MemberMinute.where('featured = false AND status=true').order(publish_date: :desc, id: :asc).page(params[:page]).per(params[:limit])
        end
        {
          status: 200,
          message: '',
          content: {:featured => Entities::Memberminute.represent(MemberMinute.where(featured: true)),
          :list => Entities::Memberminute.represent(mm)
          }
        }
      end
    end

    namespace 'memberminute-sections/:section_id' do
      params do
        requires :section_id, type: Integer
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
        ms = ::MemberMinuteSection.where('status=true').find_by_id(params[:section_id])
        {
          status: 200,
          message: '',
          content: Entities::MemberminuteSection.represent(ms,  current_user: current_user)
        }
      end
    end

    namespace 'memberminutes/archive' do
      get do
        authenticate_user
          unless  authenticated?
            return {
              status: 401,
              message: 'Unauthorized',
              content: ''
            }
          end
        years = []

        resources = MemberMinute.where("featured = false AND status=true").order('publish_date DESC')
        resource_years = resources.group_by { |t| t.publish_date.beginning_of_year }
        resource_years.sort.reverse.each do |_year, _yresources|
            months = []
            _yresources.group_by { |t| t.publish_date.beginning_of_month }.each do |_month, _mresources|
              months << {:name =>  _month.strftime("%B"), :count => _mresources.count}
            end
          years << {:name => _year.strftime("%Y") , :months => months}
        end
        {
          status: 200,
          message: '',
          content: years
        }
        end
      end

  end
end
