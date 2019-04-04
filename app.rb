require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './database.rb'
enable :sessions

before do
    if session[:answer] == nil
        session[:answer] = []
    end
end

get('/') do
    slim(:"Home/index")
end

post('/create') do
    name = params["name"]
    password = BCrypt::Password.create(params["pass"])
    db = SQLite3::Database.new('blogg.db')
    db.execute("INSERT INTO users(Username, Password) VALUES( (?), (?) )",name, password)
    redirect('/')
end




