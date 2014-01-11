require "ostruct"
require "psych"

module Power
  # Public: Static model representation of available Datacenters.
  #
  # Examples
  #
  #   Power::Datacenter.add 1, "PRN", "Prineville"
  #   Power::Datacenter.add 2, "FRC", "Forest City"
  #
  #   Power::Datacenter.by_id(1) # => #<Power::Datacenter:0x007f9ab988faf8 ...>
  #   Power::Datacenter.by_short_name("PRN1") # => #<Power::Datacenter ... >
  #   Power::Datacenter.by_slug("prineville") # => #<Power::Datacenter ... >
  class Datacenter
    attr_reader :id, :short_name, :slug, :zone_name

    attr_accessor :display_name
    attr_accessor :extra

    # Public: Add a datacenter entry to global registry.
    #
    # id         - The required Integer that identifies the datacenter.
    # short_name - The required String that represents the datacenter reference.
    # slug       - The required String that represents the datacenter URL slug.
    # zone_name  = The optional String that represents the timezone.
    #
    # Returns the created Datacenter entry.
    def self.add(id, short_name, slug, zone_name = nil)
      record = new(id, short_name, slug, zone_name)

      entries[id] ||= record
    end

    # Public: Remove all the registered Datacenters.
    #
    # Returns nothing.
    def self.clear!
      entries.clear
    end

    # Public: Return the list of registered Datacenters.
    #
    # Returns an Array of Datacenter
    def self.all
      entries.values
    end

    # Public: Return the first registered Datacenter.
    #
    # Returns a Datacenter
    # Returns nothing if no entries found.
    def self.first
      all.first
    end

    # Public: Load Datacenters from configuration file, resetting any exsting
    # entry.
    #
    # config_file - The String that points to the configuration file.
    #
    # Returns true.
    def self.from_file(config_file)
      clear!

      entries = Psych.load_file(config_file)

      entries.each do |data|
        from_data(data)
      end

      true
    end

    # Public: Find a Datacenter entry in the global registry using the
    # short_name reference.
    #
    # short_name - The String that represents the Datacenter.
    #
    # Examples
    #
    #   Power::Datacenter.by_short_name("PRN1")
    #   # => #<Power::Datacenter:0x007f9ab988faf8 ...>
    #
    #   Power::Datacenter.by_short_name("MISSING")
    #   # => nil
    #
    # Returns nothing if entry couldn't be found.
    # Returns the Datacenter entry if found.
    def self.by_short_name(short_name)
      sanitized_short_name = String(short_name)
      _, found = entries.find { |k, e| e.short_name == sanitized_short_name }
      found
    end

    # Public: Find a Datacenter entry in the global registry using the
    # ID reference.
    #
    # id - The Integer that represents the Datacenter entry.
    #
    # Examples
    #
    #   Power::Datacenter.by_id(1)
    #   # => #<Power::Datacenter:0x007f9ab988faf8 ...>
    #
    #   Power::Datacenter.by_id(99)
    #   # => nil
    #
    # Returns nothing if entry couldn't be found.
    # Returns the Datacenter entry if found.
    def self.by_id(id)
      entries[Integer(id)]
    end

    # Public: Find a Datacenter entry in the global registry using the
    # slug reference.
    #
    # slug - The String that represents the Datacenter entry.
    #
    # Examples
    #
    #   Power::Datacenter.by_slug("prineville")
    #   # => #<Power::Datacenter:0x007f9ab988faf8 ...>
    #
    #   Power::Datacenter.by_slug("missing")
    #   # => nil
    #
    # Returns nothing if entry couldn't be found.
    # Returns the Datacenter entry if found.
    def self.by_slug(slug)
      sanitized_slug = String(slug)
      _, found = entries.find { |k, e| e.slug == sanitized_slug }
      found
    end

    private

    def initialize(id, short_name, slug, zone_name = nil)
      @id         = Integer(id)
      @short_name = String(short_name)
      @slug       = String(slug)
      @zone_name  = String(zone_name)
    end

    def self.entries
      @entries ||= {}
    end

    def self.from_data(data)
      record = add(data["id"], data["short_name"],
                    data["slug"], data["zone_name"])

      record.display_name = data["display_name"]
      record.extra        = OpenStruct.new(data["extra"])

      record
    end
  end
end
