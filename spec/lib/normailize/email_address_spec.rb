require 'spec_helper'

describe Normailize::EmailAddress do
  let(:address) { Normailize::EmailAddress.new('sneaky.dude+lol@gmail.com') }

  describe '#initialize' do
    it 'accepts an email address as argument' do
      expect { Normailize::EmailAddress.new('john@doe.com') }.to_not raise_error
    end

    context 'when email address is not valid' do
      it 'raises an exception' do
        expect { Normailize::EmailAddress.new('not an @email address. sorry!') }.to raise_error(ArgumentError)
      end
    end

    context 'when email address is technically valid, but we do not accept it' do
      it 'raises an exception' do
        expect { Normailize::EmailAddress.new('" fairly.@.unusual.example.com"(&a_comment_making_it_extralong!)@[IPv6:2001:db8:23:::42]') }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#normalized_address' do
    it 'returns expected normalized address' do
      emails = {
        'rahenadibirfx+seicascoumsip@gmail.com'             => 'rahenadibirfx@gmail.com',
        'ScrapeBoxAutoa.pp.r.ovelist+427727@googlemail.com' => 'scrapeboxautoapprovelist@googlemail.com',
        'scrapeboxautoa.pp.r..ovelist+427727@gmail.com'     => 'scrapeboxautoapprovelist@gmail.com',
        'o.b.r.a.c.h.t.p.r.d.z.y.n.s.k.i+22@gmail.com'      => 'obrachtprdzynski@gmail.com',
        'z+o.e+j+ayl.e+em+a+r.t+i.n+d3u76n@gmail.com'       => 'z@gmail.com',
        'sneakydude+lol@live.com'                           => 'sneakydude@live.com'
      }

      emails.each_pair do |sneaky, expected_normalization|
        expect(Normailize::EmailAddress.new(sneaky).normalized_address).to eq(expected_normalization)
      end
    end
  end

  describe '#provider' do
    context 'when address is a @gmail.com' do
      it 'returns instance of Gmail provider' do
        expect(Normailize::EmailAddress.new('john@gmail.com').provider).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when address is a @googlemail.com' do
      it 'returns instance of Gmail provider' do
        expect(Normailize::EmailAddress.new('john@googlemail.com').provider).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when address is a @google.com' do
      it 'returns instance of Gmail provider' do
        expect(Normailize::EmailAddress.new('john@google.com').provider).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when address is a Google Apps domain' do
      it 'returns instance of Gmail provider' do
        expect(Normailize::EmailAddress.new('john@blinc.co').provider).to be_a(Normailize::Provider::Gmail)
      end
    end

    context 'when address is a @live.com' do
      it 'returns instance of Live provider' do
        expect(Normailize::EmailAddress.new('john@live.com').provider).to be_a(Normailize::Provider::Live)
      end
    end

    context 'when address is a @outlook.com' do
      it 'returns instance of Live provider' do
        expect(Normailize::EmailAddress.new('john@outlook.com').provider).to be_a(Normailize::Provider::Live)
      end
    end

    context 'when address is a @hotmail.com' do
      it 'returns instance of Hotmail provider' do
        expect(Normailize::EmailAddress.new('john@hotmail.com').provider).to be_a(Normailize::Provider::Hotmail)
      end
    end

    context 'when address is a yahoo domains' do
      it 'returns instance of Yahoo provider' do
        expect(Normailize::EmailAddress.new('john@yahoo.co.id').provider).to be_a(Normailize::Provider::Yahoo)
      end
    end

    context 'when address is a yahoo domains' do
      it 'returns instance of Yahoo provider' do
        expect(Normailize::EmailAddress.new('john@yahoo.com').provider).to be_a(Normailize::Provider::Yahoo)
      end
    end

    context 'when address is a yahoo domains' do
      it 'returns instance of Yahoo provider' do
        expect(Normailize::EmailAddress.new('john@yahoo.com.my').provider).to be_a(Normailize::Provider::Yahoo)
      end
    end

    context 'when address is a yahoo domains' do
      it 'returns instance of Yahoo provider' do
        expect(Normailize::EmailAddress.new('john@yahoo.co.th').provider).to be_a(Normailize::Provider::Yahoo)
      end
    end

    context 'when address is a @fastmail.com' do
      it 'returns instance of FastMail provider' do
        expect(Normailize::EmailAddress.new('john@fastmail.com').provider).to be_a(Normailize::Provider::FastMail)
      end
    end

    context 'when address is a @fastmail.fm' do
      it 'returns instance of FastMail provider' do
        expect(Normailize::EmailAddress.new('john@fastmail.fm').provider).to be_a(Normailize::Provider::FastMail)
      end
    end

    context 'when address is an unknown provider' do
      it 'returns instance of Generic provider' do
        expect(Normailize::EmailAddress.new('john@lazada.co.id').provider).to be_a(Normailize::Provider::Generic)
      end
    end
  end

  describe '#same_as?' do
    context 'when emails are the same' do 
      it 'returns true' do
        emails = {
          'john@gmail.com'            => 'john@gmail.com',
          'john+lol@gmail.com'        => 'john+wtf@gmail.com',
          'JoHn@gmail.com'            => 'jOhN@gmail.com',
          'jo.hn@gmail.com'           => 'j.oh.n@gmail.com',
          'Jo.h.n+lol+wtf@gmail.com'  => 'jO.h.n+lol@googlemail.com',
          'Jo.h.n+lol+wtf@google.com' => 'jO.h.n+lol@google.com',
          'john@live.com'             => 'john@live.com',
          'JoHn@live.com'             => 'jOhN@live.com',
          'john+lol@live.com'         => 'john+wtf@live.com',
          'John+lol+wtf@live.com'     => 'jOhn+lol@live.com',
          'John+lol+wtf@outlook.com'  => 'jOhn+lol@outlook.com',
          'John+lol+wtf@fastmail.com' => 'jOhn+lol@fastmail.com',
          'john@hotmail.com'          => 'john@hotmail.com',
          'john-lol@yahoo.com'        => 'john@yahoo.com',
          'john-lol@yahoo.co.id'      => 'john@yahoo.co.id',
          'John+lol+wtf@blinc.co'     => 'jOhn+lol@blinc.co', # Google Apps
        }

        emails.each_pair do |e1, e2|
          expect(Normailize::EmailAddress.new(e1)
          .same_as?(Normailize::EmailAddress.new(e2))).to be(true)
        end
      end
    end

    context 'when emails are not the same' do
      it 'returns false' do
        emails = {
          'john@gmail.com'      => 'john@live.com',
          'johnny@gmail.com'    => 'john@gmail.com',
          'john@googlemail.com' => 'john@hotmail.com',
          'john+lol@gmail.com'  => 'john+lol@live.com',
        }

        emails.each_pair do |e1, e2|
          expect(Normailize::EmailAddress.new(e1)
          .same_as?(Normailize::EmailAddress.new(e2))).to be(false)
        end
      end
    end
  end
end
