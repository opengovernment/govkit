require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Provides "String.singularize"
# which is used by resource_for_collection, in resource.rb
require 'active_support/inflector'

# Provides string.last()
# which is used by method_missing in resource.rb
require 'active_support/core_ext/string'

module GovKit::OpenStates
  describe GovKit::OpenStates do
    before(:all) do
      base_uri = GovKit::OpenStatesResource.base_uri.gsub(/\./, '\.')

      # An array of uris and filenames
      # Use FakeWeb to intercept net requests;
      # if a requested uri matches one of the following,
      # then return the contents of the corresponding file
      # as the result. 
      urls = [
        ['/bills/ca/20092010/AB667/',          'bill.response'],
        ['/bills/\?.*q=cooperatives.*',        'bill_query.response'],
        ['/bills/\?.*state=tx.*',              'bill_query.response'],
        ['/bills/\?.*q=single-employee.*',     'bill_query_single.response'],
        ['/bills/latest/\?',                   'bill_query.response'],
        ['/legislators/2462/\?',               'legislator.response'],
        ['/legislators/410/\?',                '410.response'],
        ['/legislators/401/\?',                '401.response'],
        ['/legislators/404/\?',                '404.response'],
        ['/legislators/\?.*state=zz.*',        '404.response'],
        ['/legislators/\?.*state=ca.*',        'legislator.response'],
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

    it "should have the base uri set properly" do
      [State, Bill, Legislator].each do |klass|
        klass.base_uri.should == "http://openstates.sunlightlabs.com/api/v1"
      end
    end

    it "should raise NotAuthorized if the api key is not valid" do
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

          @state.should be_an_instance_of(State)
          @state.name.should == "California"
          @state.sessions.size.should == 8
        end
      end
    end

    describe Bill do
      context "#find" do
        it "should find a bill by state abbreviation, session, chamber, bill_id" do
          lambda do
            @bill = Bill.find('ca', '20092010', 'lower', 'AB667')
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
        
        it "should return a single bill result as an array" do
          @bills = Bill.search('single-employee')
        
          @bills.should be_an_instance_of(Array)
          @bills.collect(&:bill_id).should include("SB 77")
        end

      end

      context "#latest" do
        it "should get the latest bills by given criteria" do
          lambda do
            @latest = Bill.latest('2010-01-01', :state => 'tx')
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

        it "should return an empty array if the legislator is not found" do
          @legislator = Legislator.find(404)

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
          @committees.length.should eql(20)
          com = @committees[0]
          com.should be_an_instance_of(Committee)
          com['id'].should eql('MDC000009')
        end
      end
    end
  end
end
