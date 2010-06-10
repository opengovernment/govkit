module GovKit
  module OpenCongress
    class Bill < OpenCongressObject
      attr_accessor :bill_type, :id, :introduced, :last_speech, :last_vote_date, :last_vote_roll, :last_vote_where, :last_action, :number, :plain_language_summary, :session, :sponsor, :co_sponsors, :title_full_common, :status, :most_recent_actions, :bill_titles, :recent_blogs, :recent_news, :ident
    
      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value) if Bill.instance_methods.include? key
        end      
      end
    
      def ident
        "#{session}-#{bill_type}#{number}"
      end
    
      def self.find(params)

        url = construct_url("bills", params)
      
        if (result = make_call(url))
          parse_results(result)
        else
          nil
        end

      end
    
      def self.most_blogged_bills_this_week
        url = construct_url("most_blogged_bills_this_week", {})
        if (result = make_call(url))
          bills = parse_results(result)
          return bills
        else
          nil
        end      
      end

      def self.bills_in_the_news_this_week
        url = construct_url("bills_in_the_news_this_week", {})
        if (result = make_call(url))
          bills = parse_results(result)
          return bills
        else
          nil
        end      
      end

      def self.most_tracked_bills_this_week
        url = construct_url("most_tracked_bills_this_week", {})
        if (result = make_call(url))
          bills = parse_results(result)
          return bills
        else
          nil
        end      
      end

      def self.most_supported_bills_this_week
        url = construct_url("most_supported_bills_this_week", {})
        if (result = make_call(url))
          bills = parse_results(result)
          return bills
        else
          nil
        end      
      end

      def self.most_opposed_bills_this_week
        url = construct_url("most_opposed_bills_this_week", {})
        if (result = make_call(url))
          bills = parse_results(result)
          return bills
        else
          nil
        end      
      end
    
      def self.find_by_query(q)
        url = Bill.construct_url("bills_by_query", {:q => q})
      
        if (result = make_call(url))
          bills = parse_results(result)
        else
          nil
        end
      end          

      def self.find_by_idents(idents)
        q = []
        if idents.class.to_s == "Array"
          q = idents
        else
          q = idents.split(',')
        end
      
        url = Bill.construct_url("bills_by_ident", {:ident => q.join(',')})
      
        if (result = make_call(url))
          bills = parse_results(result)
        else
          nil
        end
      end   

      def opencongress_users_supporting_bill_are_also
        url = Bill.construct_url("opencongress_users_supporting_bill_are_also/#{ident}", {})
        if (result = Bill.make_call(url))
          bills = Bill.parse_supporting_results(result)
          return bills
        else
          nil
        end
      end

      def opencongress_users_opposing_bill_are_also
        url = Bill.construct_url("opencongress_users_opposing_bill_are_also/#{ident}", {})
        if (result = Bill.make_call(url))
          bills = Bill.parse_supporting_results(result)
          return bills
        else
          nil
        end
      end
    
      def self.parse_results(result)
      
        bills = []
        result["bills"].each do |bill|
        
          these_recent_blogs = bill["recent_blogs"]
          blogs = []

          if these_recent_blogs
            these_recent_blogs.each do |trb|
              blogs << BlogPost.new(trb)
            end
          end

          bill["recent_blogs"] = blogs


          these_recent_news = bill["recent_news"]
          news = []
          if these_recent_news
            these_recent_news.each do |trb|
              news << NewsPost.new(trb)
            end
          end

          bill["recent_news"] = news

          these_co_sponsors = bill["co_sponsors"]
          co_sponsors = []
          if these_co_sponsors
            these_co_sponsors.each do |tcs|
              co_sponsors << Person.new(tcs)
            end
          end

          bill["co_sponsors"] = co_sponsors

        
          bill["sponsor"] = Person.new(bill["sponsor"]) if bill["sponsor"]
        
        
          bills << Bill.new(bill)
        end
        bills
      end

    end
  end
end
