class MembershipCancellation < ActiveRecord::Base
  belongs_to :user

  enum reason: {
    'No longer has horse'.to_sym => 1,
    'Finances'.to_sym => 4,
    'Unhappy with Program'.to_sym => 5,
    'Too much info'.to_sym => 7,
    'Not enough time'.to_sym => 11,
    'Deceased'.to_sym => 14,
    'Injured Horse'.to_sym => 15,
    'Disputed CC Charge (Chargeback)'.to_sym => 16,
    'Duplicate Account'.to_sym => 18,
    'Resigned as Professional'.to_sym => 22,
    'Health problems'.to_sym => 23,
    'Email Request'.to_sym => 24,
    'Bad Internet Service'.to_sym => 28,
    'No More Deliverables'.to_sym => 29,
    'Doesn\'t use it'.to_sym => 30,
    'Other'.to_sym => 6,
  }
end
