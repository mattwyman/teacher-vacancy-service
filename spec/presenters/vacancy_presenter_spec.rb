require 'rails_helper'
RSpec.describe VacancyPresenter do
  describe '#salary_range' do
    it 'return the formatted minimum to maximum salary' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range).to eq('£30,000 to £40,000')
    end

    it 'returns the formatted minumum to maximum salary with the specified delimiter' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range('to')).to eq('£30,000 to £40,000')
    end

    context 'when no maximum salary is set' do
      it 'should just return the minimum salary' do
        vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 20000, maximum_salary: nil))
        expect(vacancy.salary_range).to eq('£20,000')
      end
    end
  end

  describe '#expired?' do
    it 'returns true when the vacancy has expired' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 4.days.ago))
      expect(vacancy).to be_expired
    end

    it 'returns false when the vacancy expires today' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: Time.zone.today))
      expect(vacancy).not_to be_expired
    end

    it 'returns false when the vacancy has yet to expire' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 6.days.from_now))
      expect(vacancy).not_to be_expired
    end
  end

  describe '#location' do
    it 'returns the school location' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      school = SchoolPresenter.new(vacancy.school)

      expect(vacancy).to receive(:school).and_return(school)
      expect(school).to receive(:location)

      vacancy.location
    end
  end

  describe '#main_subject' do
    it 'returns the subject name' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      expect(vacancy.main_subject).to eq(vacancy.subject.name)
    end
  end

  describe '#pay_scale_range' do
    it 'returns an empty string when no pay_scale is set' do
      vacancy = VacancyPresenter.new(build(:vacancy, min_pay_scale: nil, max_pay_scale: nil))
      expect(vacancy.pay_scale_range).to eq('')
    end

    it 'returns the minimum payscale when no max_pay_scale is set' do
      vacancy = VacancyPresenter.new(build(:vacancy, max_pay_scale: nil))
      expect(vacancy.pay_scale_range).to eq(vacancy.min_pay_scale.label)
    end

    it 'returns the  payscale range when min_pay_scale and max_pay_scale are set' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      expect(vacancy.pay_scale_range).to eq("#{vacancy.min_pay_scale.label} to #{vacancy.max_pay_scale.label}")
    end
  end

  describe '#publish_today?' do
    it 'verifies that the publish_on is set to today' do
      vacancy = VacancyPresenter.new(build(:vacancy, publish_on: Time.zone.today))

      expect(vacancy.publish_today?).to eq(true)
    end
  end

  describe '#job_description' do
    it 'sanitizes and transforms the job_description into HTML' do
      vacancy = build(:vacancy, job_description: '<script> call();</script>Sanitized content')
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.job_description).to eq('<p> call();Sanitized content</p>')
    end
  end

  describe '#flexible_working' do
    context 'it converts flexible working' do
      it 'to Yes' do
        vacancy = VacancyPresenter.new(build(:vacancy, :complete))
        expect(vacancy.flexible_working).to eq('Yes')
      end

      it 'to No' do
        vacancy = VacancyPresenter.new(build(:vacancy))
        expect(vacancy.flexible_working).to eq('No')
      end
    end
  end
end
