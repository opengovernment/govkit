module GovKit
  module OpenCongress
  
    class Person < OpenCongressObject
    
      attr_accessor :firstname, :lastname, :bioguideid, :birthday, :district, :email, :gender, :id, :metavid_id, :middlename,
                    :name, :nickname, :osid, :party, :religion, :state, :title, :unaccented_name, :url, :user_approval,
                    :youtube_id, :oc_user_comments, :oc_users_tracking, :abstains_percentage, :with_party_percentage, :recent_news,
                    :recent_blogs, :person_stats
    
      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value) if Person.instance_methods.include? key
        end      
      end
    
      def self.find(params)

        url = construct_url("people", params)
        if (result = make_call(url))
          people = parse_results(result)
          return people
        else
          nil
        end

      end

      def self.compare(person1, person2)
        url = "#{GovKit::configuration.opencongress_base_url}person/compare.json?person1=#{person1.id}&person2=#{person2.id}"
        if (result = make_call(url))
          comparison = VotingComparison.new(result["comparison"])
        else
          nil
        end
      
      end

      def self.senators_most_in_the_news_this_week

        url = construct_url("senators_most_in_the_news_this_week", {})
        if (result = make_call(url))
          people = parse_results(result)
          return people
        else
          nil
        end

      end

      def self.representatives_most_in_the_news_this_week

        url = construct_url("representatives_most_in_the_news_this_week", {})
        if (result = make_call(url))
          people = parse_results(result)
          return people
        else
          nil
        end

      end

      def self.most_blogged_senators_this_week

        url = construct_url("most_blogged_senators_this_week", {})
        if (result = make_call(url))
          people = parse_results(result)
          return people
        else
          nil
        end

      end

      def self.most_blogged_representatives_this_week

        url = construct_url("most_blogged_representatives_this_week", {})
        if (result = make_call(url))
          people = parse_results(result)
          return people
        else
          nil
        end

      end
    
      def opencongress_users_supporting_person_are_also
        url = Person.construct_url("opencongress_users_supporting_person_are_also/#{id}", {})
        if (result = Person.make_call(url))
          people = Person.parse_supporting_results(result)
          return people
        else
          nil
        end
      end

      def opencongress_users_opposing_person_are_also
        url = Person.construct_url("opencongress_users_opposing_person_are_also/#{id}", {})
        if (result = Person.make_call(url))
          people = Person.parse_supporting_results(result)
          return people
        else
          nil
        end
      end

      def self.parse_results(result)

          people = []
          result["people"].each do |person|
          
            these_recent_blogs = person["recent_blogs"]
            blogs = []
            these_recent_blogs.each do |trb|
              blogs << BlogPost.new(trb)
            end

            person["recent_blogs"] = blogs


            these_recent_news = person["recent_news"]
            news = []
            these_recent_news.each do |trb|
              news << NewsPost.new(trb)
            end
          
            person["person_stats"] = PersonStat.new(person["person_stats"]) if person["person_stats"]
          
            person["recent_news"] = news
          
            people << Person.new(person)
          end      
        
          people
            
      end    
      
      
    end
  
  
  end
end