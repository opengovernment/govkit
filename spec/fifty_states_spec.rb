require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::FiftyStates
  describe GovKit::FiftyStates do
    before(:all) do
      urls = [
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/ca/\?|,                             'state.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/ca/20092010/lower/bills/AB667/|,    'bill.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/bills/search/\?|,                   'bill_query.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/bills/latest/\?|,                   'bill_query.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/legislators/2462/\?|,               'legislator.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/legislators/410/\?|,                '410.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/legislators/401/\?|,                '401.response'],
        [%r|http://fiftystates-dev\.sunlightlabs\.com/api/legislators/search/\?|,             'legislator_query.response']
      ]

      urls.each do |u|
        FakeWeb.register_uri(:get, u[0], :response => File.join(FIXTURES_DIR, 'fifty_states', u[1]))
      end
    end

    it "should have the base uri set properly" do
      [State, Bill, Legislator].each do |klass|
        klass.base_uri.should == "http://fiftystates-dev.sunlightlabs.com/api"
      end
    end

    it "should raise GovKit::NotAuthorized if the api key is not valid" do
      lambda do 
        @legislator = Legislator.find(401)
      end.should raise_error(GovKit::NotAuthorized)
      
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

          @state.should_not be_nil
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

          @bill.should_not be_nil
          @bill.title.should include("An act to amend Section 1750.1 of the Business and Professions Code, and to amend Section 104830 of")
        end
      end

      context "#search" do
        it "should find bills by given criteria" do
          @bills = Bill.search('cooperatives')

          @bills.should_not be_nil
          @bills.collect(&:bill_id).should include("SB 921")
        end
      end

      context "#latest" do
        it "should get the latest bills by given criteria" do
          lambda do
            @latest = Bill.latest('2010-01-01','tx')
          end.should_not raise_error

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

          @legislator.first_name.should == "Dave"
          @legislator.last_name.should == "Cox"
        end
        
        it "should return an error if the legislator is not found" do
          lambda do
            @legislator = Legislator.find(410)
          end.should raise_error(GovKit::ResourceNotFound)

          @legislator.should be_nil
        end
      end

      context "#search" do
        it "should get legislators by given criteria" do
          lambda do
            @legislators = Legislator.search(:state => 'ca')
          end.should_not raise_error

          @legislators.should_not be_nil
        end
      end
    
    end
  end
end
