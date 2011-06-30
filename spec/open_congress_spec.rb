require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::OpenCongress
  describe GovKit::OpenCongress do
    before(:all) do
      @oc_objs = [Bill, Person]
      base_uri = "http://www.opencongress.org/api/"
      
      # An array of uris and filenames
      # Use FakeWeb to intercept net requests;
      # if a requested uri matches one of the following,
      # then return the contents of the corresponding file
      # as the result. 
      urls = [
       [ "people?key=YOUR_OPENCONGRESS_API_KEY&district=1&state=FL&format=json", "fl01.response" ],
       [ "people?key=YOUR_OPENCONGRESS_API_KEY&district=0&state=ZZ&format=json", "empty.response" ],
       [ "most_blogged_representatives_this_week?key=YOUR_OPENCONGRESS_API_KEY&format=json", "person.response" ],
       [ "bills?key=YOUR_OPENCONGRESS_API_KEY&number=0&format=json", "empty.response" ],
       [ "bills?key=YOUR_OPENCONGRESS_API_KEY&number=501&format=json", "501.response" ],
       [ "most_blogged_bills_this_week?key=YOUR_OPENCONGRESS_API_KEY&format=json", "bill.response" ] 
      ]
      
      urls.each do |u|
        FakeWeb.register_uri(:get, "#{base_uri}#{u[0]}", :response => File.join(FIXTURES_DIR, 'open_congress', u[1]))
      end
    end
    
    it "should construct a url properly" do
      @oc_objs.each do |klass|
        klass.construct_url(klass.to_s.split("::").last, {}).should == "http://www.opencongress.org/api/#{klass.to_s.split("::").last}?key=YOUR_OPENCONGRESS_API_KEY&format=json"
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
          lambda do
            @person = Person.find(:district => 1, :state => "FL").first
          end.should_not raise_error

          @person.should be_an_instance_of(Person)
          @person.firstname.should == "Jeff"
          @person.lastname.should == "Miller"
        end
        
        it "should return an empty array when no person fits the criteria" do
          lambda do
            @person = Person.find(:district => 0, :state => "ZZ")
          end.should_not raise_error
          
          @person.should be_an_instance_of(Array)
          @person.empty?.should be_true
        end
      end
      
      context "#most blogged representatives this week" do
        it "should find reps" do
          lambda do
            @person = Person.most_blogged_representatives_this_week.first
          end.should_not raise_error

          @person.should be_an_instance_of(Person)
          @person.firstname.should == "Jeff"
          @person.lastname.should == "Miller"
        end
      end
    end
    
    describe Bill do
      context "#find" do
        it "should find a specific bill" do
          lambda do
            @bill = Bill.find(:number => 501).first
          end.should_not raise_error
        
          @bill.should be_an_instance_of(Bill)
          @bill.number.should == 501
          @bill.bill_type.should == "h"
        end
        
        it "should return an empty array when no bill fits the criteria" do
          @bill = Bill.find(:number => 0)
          
          @bill.should be_an_instance_of(Array)
          @bill.empty?.should be_true
        end
      end
      
      context "#most blogged bills this week" do
        it "should find specific bills" do
          lambda do
            @bill = Bill.most_blogged_bills_this_week.first
          end.should_not raise_error
          
          @bill.should be_an_instance_of(Bill)
          @bill.number.should == 2678
          @bill.bill_type.should == "h"
        end
      end
    end
  end
end
