# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  due_date    :date
#  category_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :integer          not null
#  code        :string
#
class Task < ApplicationRecord
  belongs_to :category
  belongs_to :owner, class_name: 'User'
  
  has_many :participating_users , class_name: 'Participant'
  has_many :participants, through: :participating_users, source: :user
  has_many :notes 
  #The next line allows us to specify what relationships are going to receive internally, information from other forms
  accepts_nested_attributes_for :participating_users, allow_destroy: true  
  
  validates :participating_users , presence: true 
  validates :name, :description, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  before_create :create_code
  after_create :send_email
  #custom validation 
  validate :due_date_validator
  

  def due_date_validator
    return if due_date.blank?
    return if due_date > Date.today
    errors.add :due_date, I18n.t('task.errors.due_date_invalid')
  end

  def create_code 
    self.code = "#{owner_id}#{Time.now.to_i.to_s(36)}#{SecureRandom.hex(8)}"
  end
  def send_email
    (participants + [owner]).each do |user|
      ParticipantMailer.with(user: user, task: self).new_task_email.deliver!
    end
  end
end
