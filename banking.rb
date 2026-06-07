require 'time'

module Logger 
  LOG_FILE = 'app.log'
  def log_info(message)
    write_log("info", message)
  end

  def log_warning(message)
    write_log("warning", message)
  end

  def log_error(message)
    write_log("error", message)
  end

  private

  def write_log(type, message)
    timestamp = Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')
    File.open(LOG_FILE, 'a') do |file|
      file.puts("#{timestamp} -- #{type} -- #{message}")
    end
  end

end

class User
  attr_accessor :name
  attr_accessor :balance
  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

class Transaction
  attr_reader :user
  attr_reader :value

  def initialize(user, value)
    @user = user
    @value = value
  end

  def to_s
    "User #{user.name} Transaction with value #{value}"
  end
end

class Bank
  def process_transactions(transactions, &callback)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class CBABank < Bank
  include Logger
  attr_accessor :users
  def initialize(users)
    @users = users
  end

  def process_transactions(transactions, &callback)
    transactions_text = transactions.map(&:to_s).join(", ")
    log_info("Processing Transactions #{transactions_text}")
    transactions.each do |transaction|
      tx_user = transaction.user
      begin
        unless @users.include?(tx_user)
          raise "#{tx_user.name} not exist in the bank!!"
        end

        new_balance = tx_user.balance + transaction.value
        if new_balance < 0
          raise "No available balance"
        end

        tx_user.balance = new_balance
        log_info("#{transaction} succeeded")

        if tx_user.balance == 0
          log_warning("#{tx_user.name} has 0 balance")
        end
        yield({ status: :success, transaction: transaction })
      rescue => e
        log_error("#{transaction} failed with message #{e.message}")
        yield({ status: :failure, transaction: transaction, reason: e.message })      
      end
    end
  end
end

bank_users = [
  User.new("Ali", 200),
  User.new("Peter", 500),
  User.new("Manda", 100)
]

out_side_bank_users = [
  User.new("Menna", 400)
]

transactions = [
  Transaction.new(bank_users[0], -20),
  Transaction.new(bank_users[0], -30),
  Transaction.new(bank_users[0], -50),
  Transaction.new(bank_users[0], -100),
  Transaction.new(bank_users[0], -100),
  Transaction.new(out_side_bank_users[0], -100)
]

cba_bank = CBABank.new(bank_users)

callback_endpoint = ->(result) do
  tx = result[:transaction]
  if result[:status] == :success
    puts "Call endpoint for success of #{tx}"
  else
    puts "Call endpoint for failure of #{tx} with reason #{result[:reason]}"
  end
end

File.delete(Logger::LOG_FILE) if File.exist?(Logger::LOG_FILE)

cba_bank.process_transactions(transactions, &callback_endpoint)

