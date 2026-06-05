require 'json'

class Book
    attr_accessor :title, :author,  :isbn
    def initialize(title, author, isbn)
        @title = title
        @author = author
        @isbn = isbn
    end

    def to_hash
        {title: @title, author: @author, isbn: @isbn}
    end
end

class Inventory
    def initialize(file_name)
        @file_name = file_name
        @books = read_file
    end

    def add_book(book)
        @books << (book)
        write_to_file
    end

    def remove_book(isbn)
        original_size = @books.size
        @books.reject! { |book| book.isbn == isbn }
        if @books.size < original_size
        write_to_file
        puts "Book with ISBN #{isbn} has been removed."
        else
        puts "No book found with ISBN #{isbn}."
        end
    end

    def list_books
        if @books.empty?
        puts "Inventory is empty."
        else
        puts "Inventory"
        @books.each do |book|
            puts "\"#{book.title}\" by #{book.author} (ISBN: #{book.isbn})"
        end
        end
    end

    private
    def read_file
        return [] unless File.exist?(@file_name)
        begin
        file_content = File.read(@file_name)
        return [] if file_content.strip.empty?
        data = JSON.parse(file_content)
        data.map { |b| Book.new(b['title'], b['author'], b['isbn']) }
        rescue JSON::ParserError
        puts "Inventory file was corrupted. Starting with an empty inventory."
        []
        end
    end

    def write_to_file()
        File.open(@file_name, 'w') do |f|
        f.write(JSON.pretty_generate(@books.map(&:to_hash)))
        end
    end
end

inventory = Inventory.new "books.json"
# inventory.list_books

book = Book.new "t3", "a3", 3
book1 = Book.new "t2", "a2", 2
book2 = Book.new "t5", "a5", 5
book3 = Book.new "t", "a", 1
inventory.add_book book
inventory.add_book book1
inventory.add_book book2
inventory.add_book book3
inventory.list_books
inventory.remove_book 3
inventory.list_books