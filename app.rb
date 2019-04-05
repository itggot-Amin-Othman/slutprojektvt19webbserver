require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './database.rb'
enable :sessions



get('/') do
    slim(:"Home/index")
end

post('/login') do
    if login(params)
    else
    end
    #kalla på funktionen login
end

post('/create') do
    result = create(params)
    if result[:error]
        result[:message]
    else
        redirect('/users/' + result[:data])
    end
    #kalla på funktionen create
end



