require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::OpenCongress
  describe GovKit::OpenCongress do
    before(:all) do
      @oc_objs = [Bill, Person]

      unless FakeWeb.allow_net_connect?
        base_uri = "http://api.opencongress.org/"

        urls = [
         [ "people?format=json&district=1&state=FL", "fl01.response" ],
         [ "people?format=json&district=0&state=ZZ", "empty.response" ],
         [ "most_blogged_representatives_this_week?format=json", "person.response" ],
         [ "bills?format=json&number=0", "empty.response" ],
         [ "bills?format=json&number=501", "501.response" ],
         [ "most_blogged_bills_this_week?format=json", "bill.response" ] 
        ]

        urls.each do |u|
          FakeWeb.register_uri(:get, "#{base_uri}#{u[0]}", :response => File.join(FIXTURES_DIR, 'open_congress', u[1]))
        end
      end
    end
    
    it "should construct a url properly" do
      @oc_objs.each do |klass|
        klass.construct_url(klass.to_s.split("::").last, {}).should == "http://api.opencongress.org/#{klass.to_s.split("::").last}?format=json"
      end
    end
    
    it "should reformat a hash to a GET request" do
      @oc_objs.each do |klass|
        klass.hash2get(:key => "key", :format => "json").should == "&key=key&format=json"
      end
    end
    
    describe Person do
      context "#find" do
        it "should find a specific person" do
          @person = Person.find(:district => 1, :state => "FL").first

          @person.should be_an_instance_of(Person)
          @person.firstname.should == "Jeff"
          @person.lastname.should == "Miller"
        end
        
        it "should return an empty array when no person fits the criteria" do
          @person = Person.find(:district => 0, :state => "ZZ")
          
          @person.should be_an_instance_of(Array)
          @person.empty?.should be_true
        end
      end
      
      context "#most blogged representatives this week" do
        it "should find reps" do
          @person = Person.most_blogged_representatives_this_week.first

          @person.should be_an_instance_of(Person)
          @person.firstname.should == "Jeff"
          @person.lastname.should == "Miller"
        end
      end
    end
    
    describe Bill do
      context "#find" do
        it "should find a specific bill" do
          @bill = Bill.find(:number => 501).first
        
          @bill.should be_an_instance_of(Bill)
          @bill.number.should == 501
          @bill.bill_type.should == (FakeWeb.allow_net_connect? ? "hr" : "h")
        end
        
        it "should return an empty array when no bill fits the criteria" do
          @bill = Bill.find(:number => 0)
          
          @bill.should be_an_instance_of(Array)
          @bill.empty?.should be_true
        end
      end
      
      context "#most blogged bills this week" do
        it "should find specific bills" do
          @bill = Bill.most_blogged_bills_this_week.first
          
          @bill.should be_an_instance_of(Bill)
          @bill.number.should == 2678
          @bill.bill_type.should == "h"
        end
      end
    end
  end
end
