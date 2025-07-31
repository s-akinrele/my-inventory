# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create 10 vendor records
vendors_data = [
  {
    name: "TechCorp Solutions",
    email: "contact@techcorp.com",
    phone: "+1-555-0101",
    address: "123 Innovation Drive, Silicon Valley, CA 94025",
    website: "https://techcorp.com"
  },
  {
    name: "Global Electronics Ltd",
    email: "info@globalelectronics.com",
    phone: "+1-555-0102",
    address: "456 Circuit Street, Austin, TX 73301",
    website: "https://globalelectronics.com"
  },
  {
    name: "Smart Devices Inc",
    email: "sales@smartdevices.com",
    phone: "+1-555-0103",
    address: "789 Tech Boulevard, Seattle, WA 98101",
    website: "https://smartdevices.com"
  },
  {
    name: "Digital Innovations Co",
    email: "hello@digitalinnovations.com",
    phone: "+1-555-0104",
    address: "321 Digital Lane, Boston, MA 02101",
    website: "https://digitalinnovations.com"
  },
  {
    name: "Future Tech Systems",
    email: "info@futuretech.com",
    phone: "+1-555-0105",
    address: "654 Future Road, San Francisco, CA 94102",
    website: "https://futuretech.com"
  },
  {
    name: "Innovation Hub",
    email: "contact@innovationhub.com",
    phone: "+1-555-0106",
    address: "987 Innovation Way, New York, NY 10001",
    website: "https://innovationhub.com"
  },
  {
    name: "Tech Solutions Pro",
    email: "support@techsolutionspro.com",
    phone: "+1-555-0107",
    address: "147 Tech Plaza, Chicago, IL 60601",
    website: "https://techsolutionspro.com"
  },
  {
    name: "Digital Dynamics",
    email: "info@digitaldynamics.com",
    phone: "+1-555-0108",
    address: "258 Digital Drive, Los Angeles, CA 90001",
    website: "https://digitaldynamics.com"
  },
  {
    name: "Smart Systems Co",
    email: "sales@smartsystems.com",
    phone: "+1-555-0109",
    address: "369 Smart Street, Miami, FL 33101",
    website: "https://smartsystems.com"
  },
  {
    name: "Advanced Technologies",
    email: "contact@advancedtech.com",
    phone: "+1-555-0110",
    address: "741 Advanced Avenue, Denver, CO 80201",
    website: "https://advancedtech.com"
  }
]

puts "Creating vendors..."
vendors_data.each do |vendor_attrs|
  vendor = Vendor.find_or_create_by!(email: vendor_attrs[:email]) do |v|
    v.name = vendor_attrs[:name]
    v.phone = vendor_attrs[:phone]
    v.address = vendor_attrs[:address]
    v.website = vendor_attrs[:website]
  end
  puts "Created vendor: #{vendor.name}"
end

puts "Seed data created successfully!"
