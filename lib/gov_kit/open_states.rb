module GovKit

  # Parent class for OpenStates resources
  # See http://openstates.sunlightlabs.com/api/
  class OpenStatesResource < Resource

    # Uses default_params from the HTTParty gem.
    # See HTTParty::ClassMethods:
    # http://rubydoc.info/gems/httparty/0.7.4/HTTParty/ClassMethods#default_params-instance_method
    default_params :output => 'json', :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.openstates_base_url
  end

  # Ruby module for interacting with the Open States Project API
  # See http://openstates.sunlightlabs.com/api/
  # Most +find+ and +search+ methods: 
  # * call HTTParty::ClassMethods#get
  # * which returns an HTTParty::Response object
  # * which is passed to GovKit::Resource#parse
  # * which uses the response to populate a Resource
  #
  module OpenStates
    ROLE_MEMBER = "member"
    ROLE_COMMITTEE_MEMBER = "committee member"
    CHAMBER_UPPER = "upper"
    CHAMBER_LOWER = "lower"

    # The State class represents the data returned from Open States.
    #
    # From the Open States documentation, at http://openstates.sunlightlabs.com/api/metadata/, 
    # the fields returned are:
    #
    #    name
    #        The name of the state
    #    abbreviation
    #        The two-letter abbreviation of the state
    #    legislature_name
    #        The name of the state legislature
    #    upper_chamber_name
    #        The name of the 'upper' chamber of the state legislature (if applicable)
    #    lower_chamber_name
    #        The name of the 'lower' chamber of the state legislature (if applicable)
    #    upper_chamber_term
    #        The length, in years, of a term for members of the 'upper' chamber (if applicable)
    #    lower_chamber_term
    #        The length, in years, of a term for members of the 'lower' chamber (if applicable)
    #    upper_chamber_title
    #        The title used to refer to members of the 'upper' chamber (if applicable)
    #    lower_chamber_title
    #        The title used to refer to members of the 'lower' chamber (if applicable)
    #    latest_dump_url
    #        URL pointing to a download of all data for the state
    #    latest_dump_date
    #        datestamp of the file at latest_dump_url
    #    terms
    #    
    #        A list of terms that we have data available for. Each session will be an object with the following fields:
    #    
    #            * start_year: The year in which this session began.
    #            * end_year: The year in which this session ended.
    #            * name: The name of this session.
    #            * sessions: List of sessions that took place inside the given term.
    #    
    #    session_details
    #    
    #        Optional extra details about sessions.
    #    
    #        If present will be a dictionary with keys corresponding to sessions and values are dictionaries of extra metadata about a session.
    #    
    #        Fields that may be present include start_date and end_date, as well as type indicating whether the session was a normally scheduled or special session.
    #    
    class State < OpenStatesResource
      def self.find_by_abbreviation(abbreviation)
        response = get("/metadata/#{abbreviation}/")
        parse(response)
      end
    end

    # The Bill class represents the data returned from Open States.
    #
    # From the Open States documentation, at http://openstates.sunlightlabs.com/api/bills/, 
    # the fields returned are:
    #
    #    title
    #        The title given to the bill by the state legislature.
    #    state
    #        The 2-letter abbreviation of the state this bill is from (e.g. ny).
    #    session
    #        The session this bill was introduced in.
    #    chamber
    #        The chamber this bill was introduced in (e.g. 'upper', 'lower')
    #    bill_id
    #        The identifier given to this bill by the state legislature (e.g. 'AB6667')
    #    type
    #        Bill type (see bill categorization).
    #    alternate_titles
    #        A list of alternate titles that this bill is/was known by, if available.
    #    updated_at
    #        Timestamp representing when bill was last updated in our system.
    #    actions
    #    
    #        A list of legislative actions performed on this bill. Each action will be an object with at least the following fields:
    #    
    #            * date: The date/time the action was performed
    #            * actor: The chamber, person, committee, etc. responsible for this action
    #            * action: A textual description of the action performed
    #            * type: A normalized type for the action, see see action categorization.
    #    
    #    sponsors
    #    
    #        A list of sponsors of this bill. Each sponsor will be an object with at least the following fields:
    #    
    #            * leg_id: An Open State Project legislator ID.
    #            * full_name: The name of the sponsor
    #            * type: The type of sponsorship (state specific, examples include 'Primary Sponsor', 'Co-Sponsor')
    #    
    #    votes
    #    
    #        A list of votes relating to this bill. Each vote will be an object with at least the following fields:
    #    
    #            * date: The date/time the vote was taken
    #            * chamber: The chamber that the vote was taken in
    #            * motion: The motion being voted on
    #            * yes_count, no_count, other_count: The number of 'yes', 'no', and other votes
    #            * yes_votes, no_votes, other_votes: The legislators voting 'yes', 'no', and other
    #            * passed: Whether or not the vote passed
    #            * type: The normalized type for the vote. See vote categorization).
    #    
    #    versions
    #    
    #        A list of versions of the text of this bill. Each version will be an object with at least the following fields:
    #    
    #            * url: The URL for an official source of this version of the bill text
    #            * name: A name for this version of the bill text
    #    
    #    documents
    #    
    #        A list of documents related to this bill. Each document will be an object with at least the following fields:
    #    
    #            * url: The URL for an official source of this document
    #            * name: A name for this document (eg. 'Fiscal Statement', 'Education Committee Report')
    #    
    #    sources
    #    
    #        List of sources that this data was collected from.
    #    
    #            * url: URL of the source
    #            * retrieved: time at which the source was last retrieved
    #    
    #    Note
    #    
    #    actions, sponsors, votes, versions, documents, alternate_title and sources are not returned via the search API.
    #    
    #    Note
    #    
    #    Keep in mind that these documented fields may be a subset of the fields provided for a given state. 
    class Bill < OpenStatesResource
      # http://openstates.sunlightlabs.com/api/v1/bills/ca/20092010/AB 667/
      def self.find(state_abbrev, session, bill_id, chamber = '')
        escaped_bill_id = bill_id.gsub(/ /, '%20')
        escaped_session = session.gsub(/ /, '%20')
        response = get("/bills/#{state_abbrev.downcase}/#{escaped_session}/#{chamber.blank? ? '' : chamber + '/'}#{escaped_bill_id}/")
        parse(response)
      end

      def self.search(query, options = {})
        response = get('/bills/', :query => {:q => query}.merge(options))
        parse(response)
      end

      def self.latest(updated_since, ops = {})
        response = get('/bills/', :query => {:updated_since => updated_since.to_s}.merge(ops))
        parse(response)
      end
    end

    # The Legislator class represents the data returned from Open States.
    #
    # From the Open States documentation, at http://openstates.sunlightlabs.com/api/legislators/, 
    # the fields returned are:
    #
    #      * leg_id: A permanent, unique identifier for this legislator within the Open State Project system.
    #      * full_name
    #      * first_name
    #      * last_name
    #      * middle_name
    #      * suffixes
    #      * photo_url
    #      * active - Boolean indicating whether or not this legislator is currently serving.
    #      * state, chamber, district, party (only present if the legislator is currently serving)
    #      * roles: A list of objects representing roles this legislator currently holds. Each role will contain at least the type and term roles:
    #            o type the type of role - e.g. "member", "committee member", "Lt. Governor"
    #            o term the term the role was held during
    #            o chamber
    #            o district
    #            o party
    #            o committee
    #            o term
    #      * old_roles: A dictionary mapping term names for past terms to lists of roles held. (Sub-objects have same fields as roles.)
    #      * sources List of sources that this data was collected from.
    #            o url: URL of the source
    #            o retrieved: time at which the source was last retrieved
    #     Note
    #     
    #     sources, roles and old_roles are not included in the legislator search response.
    #     
    #     Note
    #     
    #     Keep in mind that these documented fields may be a subset of the fields provided for a given state. 
    class Legislator < OpenStatesResource
      def self.find(legislator_id)
        response = get("/legislators/#{legislator_id}/")
        parse(response)
      end

      def self.search(options = {})
        response = get('/legislators/', :query => options)
        parse(response)
      end
    end
    
    # The Committeer class represents the data returned from Open States.
    #
    # From the Open States documentation, at http://openstates.sunlightlabs.com/api/committees/, 
    # the fields returned are:
    #
    #    Committee methods return objects with the following fields:
    #    
    #    id
    #        Open State Project Committee ID.
    #    chamber
    #        Associated chamber (upper, lower, or joint).
    #    state
    #        State abbreviation (eg. ny).
    #    committee
    #        Name of committee.
    #    subcommittee
    #        Name of subcommittee (null if record describes a top level committee).
    #    parent_id
    #        For subcommittees, the committee ID of its parent. null otherwise.
    #    members
    #    
    #        Listing of the current committee membership.
    #    
    #        legislator
    #            Name of legislator (as captured from source).
    #        role
    #            Role of this member on the committee (usually 'member' but may indicate charimanship or other special status)
    #        leg_id
    #            Legislator's Open State Project ID
    #    
    #    sources
    #    
    #        List of sources that this data was collected from.
    #    
    #        url
    #            URL of the source
    #        retrieved
    #            time at which the source was last retrieved
    #    
    #    Note
    #    
    #    members and sources are not included in the committee search API results
    #    
    #    Note
    #    
    #    Keep in mind that these documented fields may be a subset of the fields provided for a given state. (See extra fields.)
    class Committee < OpenStatesResource
      def self.find(committee_id)
        response = get("/committees/#{committee_id}/")
        parse(response)
      end

      def self.search(options = {})
        response = get('/committees/', :query => options)
        parse(response)
      end
    end
    
    class Role < OpenStatesResource; end

    class Sponsor < OpenStatesResource; end

    class Version < OpenStatesResource; end

    class Source < OpenStatesResource; end

    class Address < OpenStatesResource; end

    class Action < OpenStatesResource; end

    class Vote < OpenStatesResource
      def self.find(vote_id)
        response = get("/votes/#{vote_id}/")
        parse(response)
      end
    end
  end
end
