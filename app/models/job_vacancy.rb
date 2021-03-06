class JobVacancy < ApplicationRecord
  belongs_to :headhunter
  
  has_many :registereds
  has_many :candidates, :through => :registereds

  validates :title, :vacancy_description, :ability_description, :level,
            :limit_date, :region, presence: true
  validates :minimum_wage, numericality: {greater_than_or_equal_to: 0}
  validates :maximum_wage, numericality: true

  validate :maximun_wage_not_be_greater_than_minimum
  validate :limit_date_must_be_greater_than_today

  enum level: { trainee: 0, junior: 10, full: 20, senior: 30,
                specialist: 40, manager: 50}
  enum status: { open: 0, closed: 10}

  def heading
    "#{I18n.t(level, scope: [:enum,:levels])} | #{title}"
  end

  def verify_candidate_apply_for_vacancy(candidate_id)
    registereds.find_by(candidate_id: candidate_id).present?
  end

  def verify_status_registered_for_vacancy(candidate_id)
    if registereds.find_by(candidate_id: candidate_id).in_progress?
      true
    else 
      false
    end
  end

  protected

  def maximun_wage_not_be_greater_than_minimum
    return unless maximum_wage.present? && minimum_wage.present?

    return if minimum_wage < 0

    if minimum_wage > maximum_wage
      errors.add(:minimum_wage, 'deve ser menor que o valor maximo.')
    end
  end

  def limit_date_must_be_greater_than_today
    return unless limit_date.present?

    if limit_date <= Date.current
      errors.add(:limit_date, 'deve ser maior que a data atual.')
    end
  end

end
