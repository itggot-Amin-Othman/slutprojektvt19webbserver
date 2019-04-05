require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'
enable :sessions



get('/') do
    slim(:"Home/index")
end

post('/login') do
    response = login(params)
    if response[:error]
        response[:message]
    else
        session[:loggedin] = true
        session[:user_id] = result[0]["UserId"]
        session[:name] = params["name"]
        redirect('/profile')
    end
end

post('/create') do
    response = create(params)
    
    if response[:error]
        return response[:message]
        
    else
        redirect('/profile/#{id})
    end
end

get('/profile/:id') do
    slim :'Profile/profile'
end

