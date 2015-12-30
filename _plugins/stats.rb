module Hub
  class Stats
    OFFICE_AIRPORT_CODES = %w(
      CHI
      DCA
      IAD
      MDW
      ORD
      SFO
    ).to_set.freeze

    def self.percent_remote(site)
      percent_remote_decimal = num_remote(site).to_f / num_with_location(site)
      (percent_remote_decimal * 100).to_i
    end

    def self.assign_stats(site)
      site.data['stats'] = {
        'percent_remote' => percent_remote(site)
      }
    end

    private

    def self.is_remote?(airport_code)
      !OFFICE_AIRPORT_CODES.include?(airport_code)
    end

    def self.users_with_location(site)
      site.data['team'].select do |person|
        loc = person['location']
        loc && !loc.empty?
      end
    end

    def self.num_remote(site)
      users_with_location(site).count do |person|
        loc = person['location']
        is_remote?(loc)
      end
    end

    def self.num_with_location(site)
      users_with_location(site).size
    end
  end
end
