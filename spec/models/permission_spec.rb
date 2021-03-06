require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe '#valid?' do
    before(:each) do
      stub_const('Permission::HIRING_STAFF_USER_TO_SCHOOL_MAPPING', 'user-id' => 'school-urn')
    end

    context 'when the identifier is known' do
      it 'returns true' do
        result = described_class.new(identifier: 'user-id').valid?
        expect(result).to eq(true)
      end
    end

    context 'when the identifier is not known' do
      it 'returns false' do
        result = described_class.new(identifier: 'unknown-id').valid?
        expect(result).to eq(false)
      end
    end

    context 'when the identifier is nil' do
      it 'returns false' do
        result = described_class.new(identifier: nil).valid?
        expect(result).to eq(false)
      end
    end
  end

  describe '#school_urn' do
    before(:each) do
      stub_const('Permission::HIRING_STAFF_USER_TO_SCHOOL_MAPPING', 'user-id' => 'school-urn')
    end

    it 'returns the value that matches the identifier' do
      result = described_class.new(identifier: 'user-id').school_urn
      expect(result).to eq('school-urn')
    end

    context 'when the identifier does not match' do
      it 'returns nil' do
        result = described_class.new(identifier: 'unknown-id').school_urn
        expect(result).to eq(nil)
      end
    end

    context 'when a OVERRIDE_SCHOOL_URN is set in the ENV' do
      it 'returns that value' do
        ENV['OVERRIDE_SCHOOL_URN'] = '123'
        result = described_class.new(identifier: 'user-id').school_urn
        expect(result).to eq('123')
        ENV.delete('OVERRIDE_SCHOOL_URN')
      end
    end

    context 'when the user is part of our team and on production' do
      before(:each) do
        stub_const('Permission::TEAM_USER_TO_SCHOOL_MAPPING', 'team-id' => 'school-urn')
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'returns nil' do
        result = described_class.new(identifier: 'team-id').school_urn
        expect(result).to eq(nil)
      end
    end

    context 'when the user is part of our team and on staging' do
      before(:each) do
        stub_const('Permission::TEAM_USER_TO_SCHOOL_MAPPING', 'team-id' => 'school-urn')
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'returns nil' do
        result = described_class.new(identifier: 'team-id').school_urn
        expect(result).to eq('school-urn')
      end
    end
  end
end
