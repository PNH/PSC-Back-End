class MembershipCancellationsController < InheritedResources::Base

  private

    def membership_cancellation_params
      params.require(:membership_cancellation).permit()
    end
end

