require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::TransparencyData

  describe GovKit::TransparencyData do
    before(:all) do
      unless FakeWeb.allow_net_connect?
        base_uri = GovKit::TransparencyDataResource.base_uri.gsub(/\./, '\.')

        urls = [
          ['/contributions.json\?',                         'contributions.response'],
          ['/lobbying.json\?',                              'lobbyists_find_all.response'],
          ['/grants.json\?',                                'grants_find_all.response'],
          ['/entities.json\?apikey=&search=$',              'entities_search.response'],
          ['/entities.json\?apikey=&search=harry%20pelosi', 'entities_search_limit_0.response'],
          ['/entities.json\?apikey=&search=nancy%2Bpelosi', 'entities_search_limit_1.response'],
          ['/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/sectors.json\?apikey=&cycle=2012',  'aggregates_contributors_sectors.response'],
          ['/aggregates/pol/a_bogus_politician_id/contributors/sectors.json\?apikey=',  '404.response'],
          ['/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/type_breakdown.json\?apikey=&cycle=2012',  'aggregates_contributor_type_breakdown.response'],
          ['/aggregates/pol/a_bogus_politician_id/contributors/type_breakdown.json\?apikey=',  '404.response'],
          ['/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/industries.json\?apikey=&cycle=2012', 'top_industry.response']
        ]

        urls.each do |u|
          FakeWeb.register_uri(:get, %r|#{base_uri}#{u[0]}|, :response => File.join(FIXTURES_DIR, 'transparency_data', u[1]))
        end
      end
    end

    it "should have the base uri set properly" do
      [Contribution, Entity].each do |klass|
        klass.base_uri.should == 'http://transparencydata.com/api/1.0'
      end
    end
  end

  describe Contribution do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @contributions = Contribution.search
        end.should_not raise_error

        @contributions.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 8)
        @contributions[0].contributor_city.should eql("ANCHORAGE")
      end
    end
  end
  
  describe Entity do 
    context "#search" do
      it 'should return an empty list when no elements found' do
        lambda do
          @entities = Entity.search( "harry pelosi" )
        end.should_not raise_error

        @entities.length.should eql(0)
      end
      it 'should return a list when one element found' do
        lambda do
          @entities = Entity.search( "nancy+pelosi" )
        end.should_not raise_error

        @entities.length.should eql(FakeWeb.allow_net_connect? ? 2 : 1)
      end
    end
  end
  
  describe LobbyingRecord do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @records = LobbyingRecord.search
        end.should_not raise_error

        @records.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 5)
        @records[0].lobbyists[0].lobbyist_name.should eql('Dunn, Jennifer B')
      end
    end
  end

  describe Grant do 
    context "#search" do
      it "should find all contributions" do
        lambda do
          @records = Grant.search
        end.should_not raise_error

        @records.length.should eql(FakeWeb.allow_net_connect? ? 1000 : 3)
        @records[0].project_description.should eql('NATIONAL FLOOD INSURANCE PROGRAM')
      end
    end
  end

  describe Aggregate do
    context "#top_sector_contributors" do
      it "should find the top sector contributors for Obama in 2012" do
        lambda do
          @sector_contributors = Aggregate.top_sector_contributors('4148b26f6f1c437cb50ea9ca4699417a', { :cycle => '2012' })
        end.should_not raise_error

        @sector_contributors.length.should eql(10)
        @sector_contributors[0].sector.should eql("W")
        @sector_contributors[9].count.should eql("1589")
      end

      it 'should return a 404 error for an invalid politician ID' do
        lambda do
          @sector_contributors = Aggregate.top_sector_contributors('a_bogus_politician_id')
        end.should raise_error
      end
    end

    context "#contributor_type_breakdown" do
      it "should report the contributor type breakdown for Obama in 2012" do
        lambda do
          @type_breakdown = Aggregate.contributor_type_breakdown('4148b26f6f1c437cb50ea9ca4699417a', { :cycle => '2012' })
        end.should_not raise_error

        @type_breakdown.Individuals[1].should eql '136149229.00'
        @type_breakdown.PACs[1].should eql '-1000.00'
      end

      it 'should return a 404 error for an invalid politician ID' do
        lambda do
          @type_breakdown = Aggregate.contributor_type_breakdown('a_bogus_politician_id')
        end.should raise_error
      end
    end

    context "#top_industry_contributors" do
      it "should find the top industry contributors for Obama in 2012" do
        lambda do
          @industry_contributors = Aggregate.top_industry_contributors('4148b26f6f1c437cb50ea9ca4699417a', { :cycle => '2012' })
        end.should_not raise_error

        @industry_contributors.length.should eql(10)
        @industry_contributors[0].name.should eql("RETIRED")
        @industry_contributors[9].count.should eql("9319")
      end

      it 'should return a 404 error for an invalid politician ID' do
        lambda do
          @sector_contributors = Aggregate.top_industry_contributors('a_bogus_politician_id')
        end.should raise_error
      end
    end
  end
end

