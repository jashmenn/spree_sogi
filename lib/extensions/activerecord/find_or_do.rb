
module ActiveRecordExtensionsFindOrDo
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def find_or_initialize(params)
      find_or_do('initialize', params)
    end

    def find_or_create(params)
      find_or_do('create', params)
    end
    
    private
    
    # Find a record that matches the attributes given in the +params+ hash, or do +action+
    # to retrieve a new object with the given parameters and return that.
    def find_or_do(action, params)
      # if an id is given just find the record directly
      self.find(params[:id])

    rescue ActiveRecord::RecordNotFound => e
      attrs = {}     # hash of attributes passed in params

      # search for valid attributes in params
      self.column_names.map(&:to_sym).each do |attrib|
        # skip unknown columns, and the id field
        next if params[attrib].nil? || attrib == :id

        attrs[attrib] = params[attrib]
      end

      # no valid params given, return nil
      return nil if attrs.empty?

      # call the appropriate ActiveRecord finder method
      self.send("find_or_#{action}_by_#{attrs.keys.join('_and_')}", *attrs.values)
    end
  end
end
