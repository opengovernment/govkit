require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::OpenStates
  describe GovKit::OpenStates do
    before(:all) do
      base_uri = GovKit::OpenStatesResource.base_uri.gsub(/\./, '\.')

      urls = [
        ['/ca/\?',                             'state.response'],
        ['/bills/ca/20092010/AB667/',    'bill.response'],
        ['/bills/search/\?',                   'bill_query.response'],
        ['/bills/latest/\?',                   'bill_query.response'],
        ['/legislators/2462/\?',               'legislator.response'],
        ['/legislators/410/\?',                '410.response'],
        ['/legislators/401/\?',                '401.response'],
        ['/legislators/search/\?',             'legislator_query.response']
      ]

      urls.each do |u|
        FakeWeb.register_uri(:get, %r|#{base_uri}#{u[0]}|, :response => File.join(FIXTURES_DIR, 'open_states', u[1]))
      end
    end

    it "should have the base uri set properly" do
      [State, Bill, Legislator].each do |klass|
        klass.base_uri.should == "http://fiftystates-dev.sunlightlabs.com/api"
      end
    end

    it "should raise NotAuthorizedError if the api key is not valid" do
      # The Open States API returns a 401 Not Authorized if the API key is invalid.
      lambda do
        @legislator = Legislator.find(401)
      end.should raise_error(GovKit::NotAuthorizedError)

      @legislator.should be_nil
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
          @state.sessions.size.should == 8
        end
      end
    end

    describe Bill do
      context "#find" do
        it "should find a bill by stat abbreviation, session, chamber, bill_id" do
          lambda do
            @bill = Bill.find('ca', 20092010, 'lower', 'AB667')
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
          @bills.collect(&:bill_id).should include("SB 921")
        end
      end

      context "#latest" do
        it "should get the latest bills by given criteria" do
          lambda do
            @latest = Bill.latest('2010-01-01','tx')
          end.should_not raise_error

          @latest.should be_an_instance_of(Array)
          @latest.each do |b|
            b.should be_an_instance_of(Bill)
          end
          @latest.collect(&:bill_id).should include("SB 2236")
        end
      end
    end

    describe Legislator do
      context "#find" do
        it "should find a specific legislator" do
          lambda do
            @legislator = Legislator.find(2462)
          end.should_not raise_error

          @legislator.should be_an_instance_of(Legislator)
          @legislator.first_name.should == "Dave"
          @legislator.last_name.should == "Cox"
        end

        it "should raise a GovKitError if the legislator is not found" do
          lambda do
            @legislator = Legislator.find(410)
          end.should raise_error(GovKit::ResourceNotFoundError)

          @legislator.should be_nil
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
      end

    end
  end
end
