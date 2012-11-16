require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::OpenStates
  describe GovKit::OpenStates do
    before(:all) do
      unless FakeWeb.allow_net_connect?
        base_uri = GovKit::OpenStatesResource.base_uri.gsub(/\./, '\.')

        # @todo The fixtures are out-of-date.
        urls = [
          ['/bills/ca/20092010/lower/AB%20667/', 'bill.response'],
          ['/bills/\?.*q=cooperatives.*',        'bill_find.response'],
          ['/bills/\?.*state=tx.*',              'bill_query.response'],
          ['/legislators/CAL000088/\?',          'legislator_find.response'],
          ['/legislators/XXL123456/\?',          '401.response'],
          ['/legislators/CAL999999/\?',          '404.response'],
          ['/legislators/\?.*state=zz.*',        '404.response'],
          ['/legislators/\?.*state=ca.*',        'legislator_query.response'],
          ['/committees/MDC000012/',             'committee_find.response'],
          ['/committees/\?.*state=md',           'committee_query.response'],
          ['/metadata/ca/\?',                    'state.response']
        ]

        # First convert each of the uri strings above into regexp's before
        # passing them on to register_uri.
        #
        # Internally, before checking if a new uri string matches one of the registered uri's,
        # FakeWeb normalizes it by parsing it with URI.parse(string), and then
        # calling URI.normalize on the resulting URI.  This appears to reorder any
        # query parameters alphabetically by key.
        #
        # So the uri
        #   http://openstates.sunlightlabs.com/api/v1/legislators/?state=zz&output=json&apikey=
        # would actually not match a registered uri of
        #   ['/legislators/\?state=zz',                                  '404.response'],
        # or
        #   ['/legislators/\?state=zz*',                                 '404.response'],
        # or even
        #   ['/legislators/\?state=zz&output=json&apikey=',              '404.response'],
        #
        # But it would match a registered uri of
        #   ['/legislators/\?apikey=&output=json&state=zz',              '404.response'],
        #   or
        #   ['/legislators/\?(.*)state=zz(.*)',                          '404.response'],


        urls.each do |u|
          FakeWeb.register_uri(:get, %r|#{base_uri}#{u[0]}|, :response => File.join(FIXTURES_DIR, 'open_states', u[1]))
        end
      end
    end

    it "should have the base uri set properly" do
      [State, Bill, Legislator].each do |klass|
        klass.base_uri.should == "http://openstates.org/api/v1"
      end
    end

    it "should raise NotAuthorized if the api key is not valid" do
      api_key = GovKit.configuration.sunlight_apikey

      GovKit.configuration.sunlight_apikey = nil

      lambda do
        @legislator = Legislator.find 'XXL123456'
      end.should raise_error(GovKit::NotAuthorized)

      @legislator.should be_nil

      GovKit.configuration.sunlight_apikey = api_key
    end

    describe State do
      context "#find_by_abbreviation" do
        before do
        end

        it "should find a state by abbreviation" do
          lambda do
            @state = State.find_by_abbreviation('ca')
          end.should_not raise_error

          @state.should be_an_instance_of(State)
          @state.name.should == "California"
          @state.terms.first.sessions.size.should == 9
        end
      end
    end

    describe Bill do
      context "#find" do
        it "should find a bill by state abbreviation, session, chamber, bill_id" do
          lambda do
            @bill = Bill.find('ca', '20092010', 'AB 667', 'lower')
          end.should_not raise_error

          @bill.should be_an_instance_of(Bill)
          @bill.title.should include("An act to amend Section 1750.1 of the Business and Professions Code, and to amend Section 104830 of")
        end
      end

      context "#search" do
        it "should find bills by given criteria" do
          @bills = Bill.search('cooperatives')

          @bills.should be_an_instance_of(Array)
          @bills.each do |b|
            b.should be_an_instance_of(Bill)
          end
          @bills.collect(&:bill_id).should include("SB 207")
        end
      end

      context "#latest" do
        it "should get the latest bills by given criteria" do
          lambda do
            @latest = Bill.latest('2012-11-01', :state => 'tx')
          end.should_not raise_error

          @latest.should be_an_instance_of(Array)
          @latest.each do |b|
            b.should be_an_instance_of(Bill)
          end
          @latest.collect(&:bill_id).should include("HB 41")
        end
      end
    end

    describe Legislator do
      context "#find" do
        it "should find a specific legislator" do
          lambda do
            @legislator = Legislator.find('CAL000088')
          end.should_not raise_error

          @legislator.should be_an_instance_of(Legislator)
          @legislator.first_name.should == "Bob"
          @legislator.last_name.should == "Blumenfield"
        end

        it "should return an empty array if the legislator is not found" do
          @legislator = Legislator.find('CAL999999')

          @legislator.should eql([])
        end
      end

      context "#search" do
        it "should get legislators by given criteria" do
          lambda do
            @legislators = Legislator.search(:state => 'ca')
          end.should_not raise_error

          @legislators.should be_an_instance_of(Array)
          @legislators.each do |l|
            l.should be_an_instance_of(Legislator)
          end
        end

        it "should return an empty array if no legislators are found" do
          lambda do
            @legislators = Legislator.search(:state => 'zz')
          end.should_not raise_error

          @legislators.should be_an_instance_of(Array)
          @legislators.length.should eql(0)
        end
      end

    end

    describe Committee do
      context "#find" do
        it "should find a specific committee" do
          lambda do
            @committee = Committee.find( 'MDC000012' )
          end.should_not raise_error

          @committee.should be_an_instance_of(Committee)
          @committee['id'].should eql('MDC000012')
        end
      end
      context "#search" do
        it "should return an array of committees" do
          lambda do
            @committees = Committee.search( :state => 'md', :chamber => 'upper' )
          end.should_not raise_error

          @committees.should be_an_instance_of(Array)
          @committees.length.should eql(21)
          com = @committees[0]
          com.should be_an_instance_of(Committee)
          com['id'].should eql('MDC000001')
        end
      end
    end
  end
end
