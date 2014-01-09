module Power
  class Importer
    attr_accessor :index

    def initialize(index)
      @index = index
    end

    def import(entries)
      prepare

      index.import Array(entries)
    end

    private

    def prepare
      return if index.exists?

      index.create
      index.mapping "document", :properties => {
        :id            => { :type => "string" },
        :datacenter_id => { :type => "long" },
        :pue           => { :type => "double" },
        :wue           => { :type => "double" },
        :temperature   => { :type => "double" },
        :humidity      => { :type => "double" },
        :it_kwh        => { :type => "double" },
        :util_kwh      => { :type => "double" },
        :twu           => { :type => "double" },
        :timestamp     => { :type => "date", :format => "dateOptionalTime" }
      }
    end
  end
end
