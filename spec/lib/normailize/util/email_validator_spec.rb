require 'spec_helper'

describe Normailize::EmailAddress do

  context 'when validate_account is true' do
    let(:options) { { validate_account: true } }

    describe '#initialize' do
      it 'accepts an email address as argument' do
        expect { Normailize::Util::EmailValidator.new('john@doe.com', options) }.to_not raise_error
      end

      context 'when email address is not valid' do
        it 'raises an exception' do
          expect { Normailize::Util::EmailValidator.new('not an @email address. sorry!', options) }.to raise_error(ArgumentError)
        end
      end

      context 'given email address with catch-all policy server' do
        let(:email) { '123-catch-all-xyzfdas@gamail.com' }
        
        it 'returns instace of EmailValidator with catch_all equals true' do
          expect(Normailize::Util::EmailValidator.new(email, options).catch_all).to be(true)
        end
      end

      context 'given valid domain' do
        context 'and given non existing account' do
          let(:email) { '123-catch-all-xyzfdas@gamil.com' }
          let(:ev) { Normailize::Util::EmailValidator.new(email, options) }
          
          it 'returns instace of EmailValidator with did_you_mean' do
            expect(ev.did_you_mean).to eq('123-catch-all-xyzfdas@gmail.com')
          end
        end
      end

    end
  end

end

