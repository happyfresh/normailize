require 'spec_helper'

describe Normailize::Provider::Live do
  subject { Normailize::Provider::Live.new('live.com') }

  it 'includes the Provider module' do
    expect(subject).to be_a(Normailize::Provider)
  end

  it 'is not a generic provider' do
    expect(subject).to_not be(Normailize::Provider::Generic)
  end

  describe '.domains' do
    subject { Normailize::Provider::Live.domains }

    it 'includes live.com' do
      expect(subject).to include('live.com')
    end

    it 'includes outlook.com' do
      expect(subject).to include('outlook.com')
    end
  end

  describe '#modifications' do
    subject { Normailize::Provider::Live.new('live.com').modifications }

    it 'lowercases emails' do
      expect(subject).to include(:lowercase)
    end

    it 'does not remove dots' do
      expect(subject).to_not include(:remove_dots)
    end

    it 'removes plus parts' do
      expect(subject).to include(:remove_plus_part)
    end
  end

  describe '#same_as?' do
    context 'when comparing a provider of the same type' do
      it 'returns true' do
        expect(subject.same_as?(Normailize::Provider::Live.new('live.com'))).to be(true)
      end
    end

    context 'when comparing a generic provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Generic.new('somewhere.com'))).to be(false)
      end
    end

    context 'when comparing a Hotmail provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Hotmail.new('hotmail.com'))).to be(false)
      end
    end
  end
end
