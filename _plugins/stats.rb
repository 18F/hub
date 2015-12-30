class Stats < Jekyll::Generator
  OFFICE_AIRPORT_CODES = %w(
    CHI
    DCA
    IAD
    MDW
    ORD
    SFO
  ).to_set.freeze

  def generate(site)
    site.data['stats'] = {
      'percent_remote' => percent_remote(site)
    }
  end

  private

  def is_remote?(airport_code)
    !OFFICE_AIRPORT_CODES.include?(airport_code)
  end

  def users_with_location(site)
    site.data['team'].select do |person|
      loc = person['location']
      loc && !loc.empty?
    end
  end

  def num_remote(site)
    users_with_location(site).count do |person|
      loc = person['location']
      is_remote?(loc)
    end
  end

  def num_with_location(site)
    users_with_location(site).size
  end

  def percent_remote(site)
    ((num_remote(site).to_f / num_with_location(site)) * 100).to_i
  end
end
