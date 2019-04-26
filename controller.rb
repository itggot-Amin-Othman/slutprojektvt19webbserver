require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'json'
require_relative './model.rb'
enable :sessions

before do
    if session[:history] == nil
        session[:history] = []
    end
end

get('/') do
    slim(:"Shared/index")
end

get('/comrades') do
    slim(:"Shared/comrades")
end

post('/login') do
    response = login(params)
    if response[:error]
        response[:message]
    else
        session[:loggedin] = true
        session[:user_id] = response[:data][0]
        session[:name] = params["name"]
        id = session[:user_id]
        redirect("/profile/#{id}")
    end
end

post('/create') do
    response = create(params)
    id = response[:data]
    if response[:error]
        return response[:message]
    else
        redirect("/profile/#{id}")
    end
end

get('/profile/:id') do
   slim(:'Profile/profile', locals:{
        # personens fucking information
   })
end

post('/save_math')  do
    session[:history] << params["history"][0] 
    response = addhistory(params)
    if response[:error]
        return response[:message]
    else
        return response[:message]
    end
    redirect("/")
end