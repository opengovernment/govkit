require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::OpenCongress
  describe GovKit::OpenCongress do
    before(:all) do
      base_uri = "http://www.opencongress.org/api/"
      
      # An array of uris and filenames
      # Use FakeWeb to intercept net requests;
      # if a requested uri matches one of the following,
      # then return the contents of the corresponding file
      # as the result. 
      urls = [
       [ "people?key=YOUR_OPENCONGRESS_API_KEY&district=1&state=FL&format=json", "person.response" ],
       [ "most_blogged_bills_this_week?key=YOUR_OPENCONGRESS_API_KEY&format=json", "bill.response" ]
      ]
      
      urls.each do |u|
        FakeWeb.register_uri(:get, "#{base_uri}#{u[0]}", :response => File.join(FIXTURES_DIR, 'open_congress', u[1]))
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
      end
    end
    
    describe Bill do
      context "#most_blogged_bills_this_week" do
        it "should find specific bills" do
          lambda do
            @bill = Bill.most_blogged_bills_this_week.first
          end.should_not raise_error
          
          @bill.should be_an_instance_of(Bill)
          @bill.number.should == 782
          @bill.bill_type.should == "s"
        end
      end
    end
  end
end
