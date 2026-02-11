# Helper for clean seeding
def clean_database
  puts "Cleaning database..."
  User.destroy_all # This will cascade delete transactions, stats, etc. Due to dependent: :destroy
  AuditLog.destroy_all
end

clean_database

puts "Seeding demo data with ALL scenarios..."

# Scenarios to cover:
# 1. Success (Normal spending)
# 2. Flagged (Medium risk: Amount deviation, Velocity)
# 3. Blocked (High risk: Very high amount, Unknown device, Multiple rapid txns)

# Create 5 Demo Customers with specific patterns
users_data = [
  { first_name: "John", last_name: "Success", email: "john@example.com", pattern: :mostly_success },
  { first_name: "Jane", last_name: "Flagged", email: "jane@example.com", pattern: :frequent_flagged },
  { first_name: "Bob", last_name: "Blocked", email: "bob@example.com", pattern: :mostly_blocked },
  { first_name: "Alice", last_name: "Varied", email: "alice@example.com", pattern: :all_scenarios },
  { first_name: "Charlie", last_name: "Baseline", email: "charlie@example.com", pattern: :low_activity }
]

users = users_data.map do |data|
  user = User.create!(
    first_name: data[:first_name],
    last_name: data[:last_name],
    email: data[:email],
    password: "password123",
    password_confirmation: "password123",
    role: :customer,
    status: :active
  )
  puts "Created user: #{user.email} (Pattern: #{data[:pattern]})"

  # Set up persistent device for normal behavior
  trusted_device_id = Digest::SHA256.hexdigest("trusted_device_#{user.id}")

  # Add some initial normal transactions to establish a baseline
  3.times do |i|
    txn = user.transactions.create!(
      amount: rand(100..1000),
      payment_method: [ :card, :upi ].sample,
      status: :pending,
      device_id: trusted_device_id,
      ip_address: "192.168.1.#{10 + i}"
    )
    TransactionRiskEvaluator.new(txn).evaluate
  end

  { user: user, trusted_device_id: trusted_device_id, pattern: data[:pattern] }
end

# Process specific patterns
users.each do |data|
  user = data[:user]
  trusted_device_id = data[:trusted_device_id]

  case data[:pattern]
  when :mostly_success
    # Normal spending
    5.times do |i|
      txn = user.transactions.create!(
        amount: rand(200..1500),
        payment_method: :card,
        status: :pending,
        device_id: trusted_device_id,
        ip_address: "192.168.1.50"
      )
      TransactionRiskEvaluator.new(txn).evaluate
    end

  when :frequent_flagged
    # Trigger Amount Deviation (Medium)
    puts "Generating Flagged txns for #{user.email}..."
    txn = user.transactions.create!(
      amount: 15000, # Avg from baseline is ~500, so 30x
      payment_method: :upi,
      status: :pending,
      device_id: trusted_device_id,
      ip_address: "192.168.1.60"
    )
    TransactionRiskEvaluator.new(txn).evaluate # Should be flagged

    # Trigger Velocity (Medium)
    4.times do
      txn = user.transactions.create!(
        amount: 5000,
        payment_method: :wallet,
        status: :pending,
        device_id: trusted_device_id,
        ip_address: "192.168.1.60"
      )
      TransactionRiskEvaluator.new(txn).evaluate
    end

  when :mostly_blocked
    # Trigger Blocked (High Amount)
    puts "Generating Blocked txns for #{user.email}..."
    txn = user.transactions.create!(
      amount: 250000,
      payment_method: :bank_transfer,
      status: :pending,
      device_id: "malicious_device_hash",
      ip_address: "45.0.0.1"
    )
    TransactionRiskEvaluator.new(txn).evaluate # Should be blocked

    # Trigger Blocked (Rapid Large Amounts)
    3.times do
      txn = user.transactions.create!(
        amount: 80000,
        payment_method: :card,
        status: :pending,
        device_id: trusted_device_id,
        ip_address: "192.168.1.70"
      )
      TransactionRiskEvaluator.new(txn).evaluate
    end

  when :all_scenarios
    # A mix of everything
    [ 500, 20000, 150000 ].each_with_index do |amt, i|
      txn = user.transactions.create!(
        amount: amt,
        payment_method: :upi,
        status: :pending,
        device_id: i == 2 ? "different_device" : trusted_device_id,
        ip_address: "192.168.1.#{80 + i}"
      )
      TransactionRiskEvaluator.new(txn).evaluate
    end

  when :low_activity
    # Just the baseline
  end
end

puts "Seeding completed successfully!"
puts "Summary:"
puts "Users: #{User.count}"
puts "Transactions: #{Transaction.count}"
puts "Success: #{Transaction.success.count}"
puts "Flagged: #{Transaction.flagged.count}"
puts "Blocked: #{Transaction.blocked.count}"
puts "Audit Logs: #{AuditLog.count}"
