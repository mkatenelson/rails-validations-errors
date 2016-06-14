# Empty all airplanes from the database
Airplane.destroy_all

# Populate 20 airplanes using FFaker
airplane_seed_data = Array.new(20).map do
  { name: [FFaker::Company.name, "Airlines"].join(" "),
    description: FFaker::HipsterIpsum.paragraph }
end

# Save airplanes to the database
Airplane.create(airplane_seed_data)