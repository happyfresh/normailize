require 'spec_helper'

describe Normailize::Provider::Yahoo do
  subject { Normailize::Provider::Yahoo.new('yahoo.com') }

  it 'includes the Provider module' do
    expect(subject).to be_a(Normailize::Provider)
  end

  it 'is not a generic provider' do
    expect(subject).to_not be_a(Normailize::Provider::Generic)
  end

  describe '.domains' do
    subject { Normailize::Provider::Yahoo.domains }

    it 'includes yahoo.com' do
      expect(subject).to include('yahoo.com')
    end

    it 'includes yahoo.co.id' do
      expect(subject).to include('yahoo.co.id')
    end

    it 'includes yahoo.com.my' do
      expect(subject).to include('yahoo.com.my')
    end

    it 'includes rocketmail.com' do
      expect(subject).to include('rocketmail.com')
    end
  end

  describe '#modifications' do
    subject { Normailize::Provider::Yahoo.new('yahoo.com').modifications }

    it 'lowercases emails' do
      expect(subject).to include(:lowercase)
    end

    it 'does not remove dots' do
      expect(subject).to_not include(:remove_dots)
    end

    it 'does not remove plus parts' do
      expect(subject).to_not include(:remove_plus_part)
    end

    it 'removes hyphen parts' do
      expect(subject).to include(:remove_hyphen_part)
    end
  end

  describe '#same_as?' do
    context 'when comparing a provider of the same type' do
      it 'returns true' do
        expect(subject.same_as?(Normailize::Provider::Yahoo.new('yahoo.com'))).to be(true)
      end
    end

    context 'when comparing a generic provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Generic.new('somewhere.com'))).to be(false)
      end
    end

    context 'when comparing a Gmail provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Gmail.new('gmail.com'))).to be(false)
      end
    end
  end
end
