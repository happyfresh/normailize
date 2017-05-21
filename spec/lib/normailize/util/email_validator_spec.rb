require 'spec_helper'

describe Normailize::Util::EmailValidator do

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

      it 'returns expected deliverability, did_you_mean, disposable, catch_all' do
        emails = {
          'praja21@gmail.com' => [Normailize::Util::EmailValidator::DELIVERABLE, nil, false, false],
          'tomcruise@aol.com' => [Normailize::Util::EmailValidator::UNKNOWN, nil, false, false],
          'john@gmail.com'    => [Normailize::Util::EmailValidator::UNDELIVERABLE, nil, false, false],
          'admin@happyrecipe.com' => [Normailize::Util::EmailValidator::DELIVERABLE, nil, false, false],
          'x@mailinator.com' => [Normailize::Util::EmailValidator::DELIVERABLE, nil, true, true],
          'x@yopmail.com' => [Normailize::Util::EmailValidator::DELIVERABLE, nil, true, true],
          'x@gamil.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@gmail.com', false, false],
          'x@hotmaill.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@hotmail.com', false, false],
          'x@hoymail.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@hotmail.com', false, false],
          'x@yahoo.co' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@yahoo.com', false, false],
          'x@n.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, nil, false, false],
          'x@honmail.com' => [Normailize::Util::EmailValidator::UNKNOWN, 'x@hotmail.com', false, false],
          'nE4Aw9TUuRENqUe@gmail.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, nil, false, false],
          'x@gmail.comcom' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@gmail.com', false, false],
          'x@live.con' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@live.com', false, false],
          'x@gnail.com' => [Normailize::Util::EmailValidator::UNDELIVERABLE, 'x@gmail.com', false, false]
        }

        emails.each_pair do |email, expected_value|
          ev = Normailize::Util::EmailValidator.new(email, options)

          expect(ev.deliverability).to eq(expected_value[0])
          expect(ev.did_you_mean).to eq(expected_value[1])
          expect(ev.disposable).to eq(expected_value[2])
          expect(ev.catch_all).to eq(expected_value[3])
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

    describe '#normalized_address' do
      context 'given disposable email' do
        it 'returns false' do
          expect(Normailize::Util::EmailValidator.new('temp@mailinator.com', options).valid?)
          .to eq(false)
        end
      end

      context 'given invalid email' do
        it 'returns false' do
          expect(Normailize::Util::EmailValidator.new('nonexistsfdnvelajkfdsb@gmail.com', options).valid?)
          .to eq(false)
        end

        it 'returns false' do
          expect(Normailize::Util::EmailValidator.new('someemail@aol.com', options).valid?)
          .to eq(false)
        end
      end
    end
  end

end

