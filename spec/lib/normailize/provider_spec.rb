require 'spec_helper'

describe Normailize::Provider do
  describe '.factory' do
    context 'when given gmail.com as domain' do
      it 'returns the Gmail provider' do
        expect(Normailize::Provider.factory('gmail.com')).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when given googlemail.com as domain' do
      it 'returns the Gmail provider' do
        expect(Normailize::Provider.factory('googlemail.com')).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when given google.com as domain' do
      it 'returns the Gmail provider' do
        expect(Normailize::Provider.factory('google.com')).to be_a(Normailize::Provider::Gmail)
      end
    end

    # context 'when given blinc.co (Google Apps) as domain' do
    #   it 'returns the Gmail provider' do
    #     expect(Normailize::Provider.factory('blinc.co')).to be_a(Normailize::Provider::Gmail)
    #   end
    # end

    context 'when given live.com as domain' do
      it 'returns the Live provider' do
        expect(Normailize::Provider.factory('live.com')).to be_a(Normailize::Provider::Live)
      end
    end

    context 'when given outlook.com as domain' do
      it 'returns the Live provider' do
        expect(Normailize::Provider.factory('outlook.com')).to be_a(Normailize::Provider::Live)
      end
    end

    context 'when given hotmail.com as domain' do
      it 'returns the Hotmail provider' do
        expect(Normailize::Provider.factory('hotmail.com')).to be_a(Normailize::Provider::Hotmail)
      end
    end

    context 'when given fastmail.com as domain' do
      it 'returns the FastMail provider' do
        expect(Normailize::Provider.factory('fastmail.com')).to be_a(Normailize::Provider::FastMail)
      end
    end

    context 'when given fastmail.fm as domain' do
      it 'returns the FastMail provider' do
        expect(Normailize::Provider.factory('fastmail.fm')).to be_a(Normailize::Provider::FastMail)
      end
    end

    context 'when given yahoo.com as domain' do
      it 'returns the Yahoo provider' do
        expect(Normailize::Provider.factory('yahoo.com')).to be_a(Normailize::Provider::Yahoo)
      end
    end

    context 'when given an unknown domain' do
      it 'returns instance of Generic provider' do
        expect(Normailize::Provider.factory('somewhere.com')).to be_a(Normailize::Provider::Generic)
      end
    end
  end
end
