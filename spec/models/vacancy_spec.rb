require 'rails_helper'

RSpec.describe Vacancy, type: :model do
  subject { Vacancy.new(school: build(:school)) }
  it { should belong_to(:school) }
  it { should validate_presence_of(:job_title) }
  it { should validate_presence_of(:headline) }
  it { should validate_presence_of(:job_description) }
  it { should validate_presence_of(:minimum_salary) }
  it { should validate_presence_of(:essential_requirements) }
  it { should validate_presence_of(:working_pattern) }
  it { should validate_presence_of(:publish_on) }
  it { should validate_presence_of(:expires_on) }

  describe 'applicable scope' do
    it 'should only find current vacancies' do
      expired = create(:vacancy, expires_on: 1.day.ago)
      expires_today = create(:vacancy, expires_on: Time.zone.today)
      expires_future = create(:vacancy, expires_on: 3.months.from_now)

      results = Vacancy.applicable
      expect(results).to include(expires_today)
      expect(results).to include(expires_future)
      expect(results).to_not include(expired)
    end
  end

  describe 'delegate school_name' do
    it 'should return the school name for the vacancy' do
      school = create(:school, name: 'St James School')
      vacancy = create(:vacancy, school: school)

      expect(vacancy.school_name).to eq('St James School')
    end
  end

  describe '#location' do
    it 'should return a comma separated location of the school' do
      school = create(:school, name: 'Acme School', town: 'Acme', county: 'Kent')
      vacancy = create(:vacancy, school: school)
      expect(vacancy.location).to eq('Acme School, Acme, Kent')
    end

    context 'when one of the properties is empty' do
      it 'should not include that property' do
        school = create(:school, name: 'Acme School', town: '', county: 'Kent')
        vacancy = create(:vacancy, school: school)
        expect(vacancy.location).to eq('Acme School, Kent')
      end
    end
  end

  describe '#expired?' do
    it 'returns true when the vacancy has expired' do
      vacancy = build(:vacancy, expires_on: 4.days.ago)
      expect(vacancy).to be_expired
    end

    it 'returns false when the vacancy expires today' do
      vacancy = build(:vacancy, expires_on: Time.zone.today)
      expect(vacancy).not_to be_expired
    end

    it 'returns false when the vacancy has yet to expire' do
      vacancy = build(:vacancy, expires_on: 6.days.from_now)
      expect(vacancy).not_to be_expired
    end
  end
end
