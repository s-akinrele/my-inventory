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

# Create products for each vendor
puts "\nCreating products..."

# Product data for each vendor
products_data = {
  "TechCorp Solutions" => [
    { title: "Ultra HD 4K Monitor", description: "32-inch 4K Ultra HD monitor with HDR support", price: 599.99, sku: "TECH-4K-32" },
    { title: "Wireless Mechanical Keyboard", description: "RGB mechanical keyboard with wireless connectivity", price: 129.99, sku: "TECH-KB-WIRE" },
    { title: "USB-C Docking Station", description: "Universal docking station with multiple ports", price: 89.99, sku: "TECH-DOCK-UC" }
  ],
  "Global Electronics Ltd" => [
    { title: "Smart LED Strip Lights", description: "WiFi-enabled RGB LED strip with app control", price: 49.99, sku: "GLOB-LED-WIFI" },
    { title: "Bluetooth Speaker System", description: "Portable waterproof Bluetooth speaker", price: 79.99, sku: "GLOB-SPK-BT" },
    { title: "Wireless Charging Pad", description: "Fast wireless charging pad for smartphones", price: 34.99, sku: "GLOB-CHRG-WIRE" }
  ],
  "Smart Devices Inc" => [
    { title: "Smart Home Hub", description: "Central hub for smart home automation", price: 199.99, sku: "SMART-HUB-CENT" },
    { title: "Security Camera System", description: "4-camera wireless security system", price: 299.99, sku: "SMART-CAM-4PK" },
    { title: "Smart Thermostat", description: "WiFi-enabled smart thermostat with AI", price: 149.99, sku: "SMART-THERM-AI" }
  ],
  "Digital Innovations Co" => [
    { title: "VR Gaming Headset", description: "High-end virtual reality gaming headset", price: 399.99, sku: "DIGI-VR-GAME" },
    { title: "3D Printer Kit", description: "DIY 3D printer kit with heated bed", price: 249.99, sku: "DIGI-3D-KIT" },
    { title: "Digital Drawing Tablet", description: "Professional drawing tablet with stylus", price: 179.99, sku: "DIGI-TABLET-PRO" }
  ],
  "Future Tech Systems" => [
    { title: "AI Assistant Device", description: "Voice-controlled AI assistant with smart home integration", price: 159.99, sku: "FUTURE-AI-VOICE" },
    { title: "Smart Mirror Display", description: "Interactive smart mirror with health tracking", price: 899.99, sku: "FUTURE-MIRROR-SMART" },
    { title: "Robotic Vacuum Cleaner", description: "AI-powered robotic vacuum with mapping", price: 399.99, sku: "FUTURE-ROBOT-VAC" }
  ],
  "Innovation Hub" => [
    { title: "Smart Watch Pro", description: "Advanced smartwatch with health monitoring", price: 299.99, sku: "INNOV-WATCH-PRO" },
    { title: "Wireless Earbuds", description: "Noise-cancelling wireless earbuds", price: 129.99, sku: "INNOV-EARBUDS-NC" },
    { title: "Portable Projector", description: "Mini portable projector with WiFi connectivity", price: 199.99, sku: "INNOV-PROJ-MINI" }
  ],
  "Tech Solutions Pro" => [
    { title: "Network Switch 24-Port", description: "Professional 24-port gigabit network switch", price: 449.99, sku: "TECH-SW-24GB" },
    { title: "Server Rack Mount", description: "4U server rack mount with cooling", price: 599.99, sku: "TECH-RACK-4U" },
    { title: "Backup Power Supply", description: "Uninterruptible power supply for servers", price: 299.99, sku: "TECH-UPS-SERVER" }
  ],
  "Digital Dynamics" => [
    { title: "Video Editing Workstation", description: "High-performance video editing computer", price: 2499.99, sku: "DIGI-WORK-VIDEO" },
    { title: "Professional Microphone", description: "Studio-quality USB condenser microphone", price: 89.99, sku: "DIGI-MIC-STUDIO" },
    { title: "Streaming Camera", description: "4K streaming camera with autofocus", price: 199.99, sku: "DIGI-CAM-4K" }
  ],
  "Smart Systems Co" => [
    { title: "Smart Door Lock", description: "WiFi-enabled smart door lock with keypad", price: 179.99, sku: "SMART-LOCK-WIFI" },
    { title: "Smart Garage Door Opener", description: "Smart garage door opener with app control", price: 129.99, sku: "SMART-GARAGE-APP" },
    { title: "Smart Light Bulbs Pack", description: "Pack of 4 smart LED bulbs with color control", price: 59.99, sku: "SMART-BULB-4PK" }
  ],
  "Advanced Technologies" => [
    { title: "Quantum Computing Kit", description: "Educational quantum computing development kit", price: 1999.99, sku: "ADV-QUANTUM-KIT" },
    { title: "Holographic Display", description: "Portable holographic projection display", price: 799.99, sku: "ADV-HOLO-PORT" },
    { title: "Neural Interface Device", description: "Brain-computer interface development kit", price: 1499.99, sku: "ADV-NEURAL-BCI" }
  ]
}

# Create products for each vendor
vendors_data.each do |vendor_attrs|
  vendor = Vendor.find_by(email: vendor_attrs[:email])
  next unless vendor

  vendor_products = products_data[vendor.name] || []
  vendor_products.each do |product_attrs|
    product = Product.find_or_create_by!(sku: product_attrs[:sku]) do |p|
      p.title = product_attrs[:title]
      p.description = product_attrs[:description]
      p.price = product_attrs[:price]
      p.vendor = vendor
    end
    puts "Created product: #{product.title} for #{vendor.name}"
  end
end

puts "\nSeed data created successfully!"
puts "Total vendors: #{Vendor.count}"
puts "Total products: #{Product.count}"
