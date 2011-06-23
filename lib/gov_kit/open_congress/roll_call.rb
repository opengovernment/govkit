module GovKit
  module OpenCongress
    class RollCall < OpenCongressObject
    
      attr_accessor :abstains, :presents, :roll_type, :title, :question, :republican_position, :democratic_position,
                    :amendment_id, :ayes, :nays, :bill, :date, :number, :id, :required, :where
       
      def initialize(params)
        super RollCall, params
      end
      
    end
  end
end
