require 'spec_helper'

describe Normailize::Provider::Generic do
  subject { Normailize::Provider::Generic.new('somewhere.com') }

  it 'includes the Provider module' do
    expect(subject).to be_a(Normailize::Provider)
  end

  it 'is a generic provider' do
    expect(subject).to be_a(Normailize::Provider::Generic)
  end

  describe '.domains' do
    subject { Normailize::Provider::Generic.domains }

    it 'does not include any domains' do
      expect(subject).to be_nil
    end
  end

  describe '#modifications' do
    subject { Normailize::Provider::Generic.new('somewhere.com').modifications }

    it 'does not contain any modifications' do
      expect(subject).to be_empty
    end
  end

  describe '#same_as?' do
    context 'when comparing a provider of the same type' do
      it 'returns true' do
        expect(subject.same_as?(Normailize::Provider::Generic.new('somewhere.com'))).to be(true)
      end
    end

    context 'when comparing a generic provider with a different domain' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Generic.new('somewhereelse.com'))).to be(false)
      end
    end

    context 'when comparing a Gmail provider' do
      it 'returns false' do
        expect(subject.same_as?(Normailize::Provider::Gmail.new('gmail.com'))).to be(false)
      end
    end
  end
end
