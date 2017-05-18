require 'spec_helper'

describe Normailize::Provider::Hotmail do
  subject { Normailize::Provider::Hotmail.new('hotmail.com') }

  it 'includes the Provider module' do
    expect(subject).to be_a(Normailize::Provider)
  end

  it 'is not a generic provider' do
    expect(subject).to_not be_a(Normailize::Provider::Generic)
  end

  describe '.domains' do
    subject { Normailize::Provider::Hotmail.domains }

    it 'includes hotmail.com' do
      expect(subject).to include('hotmail.com')
    end

    it 'includes msn.com' do
      expect(subject).to include('msn.com')
    end
  end

  describe '#modifications' do
    subject { Normailize::Provider::Hotmail.new('hotmail.com').modifications }

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
        expect(subject.same_as?(Normailize::Provider::Hotmail.new('hotmail.com'))).to be(true)
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
