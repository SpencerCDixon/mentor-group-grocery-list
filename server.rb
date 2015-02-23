require 'sinatra'
require 'pry'
require 'pg'


def db_connection
  begin
    connection = PG.connect(dbname: "grocery-list")
    yield(connection)
  ensure
    connection.close
  end
end

def get_items
  grocery_items = db_connection do |conn|
    conn.exec('SELECT * FROM grocery_items')
  end
  grocery_items.to_a
end

def add_grocery_item(item_name)
  db_connection do |conn|
    conn.exec_params('INSERT into grocery_items (item) VALUES ($1)', [item_name])
  end
end

def find_item_by_name(some_name)
  db_connection do |conn|
    conn.exec_params('SELECT name FROM grocery_items (name) VALUES ($1)', [some_name])
  end
end

get '/items' do
  @items = get_items
  erb :'items/index'
end

post '/items' do
  item = params["item"]
  add_grocery_item(item)

  redirect '/items'
end
