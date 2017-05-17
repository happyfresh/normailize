require 'spec_helper'

describe Normailize::Provider::Gmail do
  subject { Normailize::Provider::Gmail.new('gmail.com') }

  it 'includes the Provider module' do
    expect(subject).to be_a(Normailize::Provider)
  end

  it 'is not a generic provider' do
    expect(subject).not_to be_a(Normailize::Provider::Generic)
  end

  describe '.domains' do
    subject { Normailize::Provider::Gmail.domains }

    it 'includes gmail.com' do
      expect(subject).to include('gmail.com')
    end

    it 'includes googlemail.com' do
      expect(subject).to include('googlemail.com')
    end

    it 'includes google.com' do
      expect(subject).to include('google.com')
    end
  end

  describe '#modifications' do
    subject { Normailize::Provider::Gmail.new('gmail.com').modifications }

    it 'lowercases emails' do
      expect(subject).to include(:lowercase)
    end

    it 'removes dots' do
      expect(subject).to include(:remove_dots)
    end

    it 'removes plus parts' do
      expect(subject).to include(:remove_plus_part)
    end
  end

  describe '#same_as?' do
    context 'when comparing a provider of the same type' do
      it 'returns true' do
        expect(subject.same_as?(Normailize::Provider::Gmail.new('gmail.com'))).to be(true)
      end
    end

    context 'when comparing a generic provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Generic.new('somewhere.co'))).to be(false)
      end
    end

    context 'when comparing a Hotmail provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Hotmail.new('hotmail.com'))).to be(false)
      end
    end
  end
end
