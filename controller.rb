require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'json'
require_relative './model.rb'
enable :sessions

secure_routes = ['/profile/:id','/comrades','/profile/:id/delete']

before do
    if session[:history] == nil
        session[:history] = []
    end
end

before do
    if secure_routes.include? request.path()
        if session[:loggedin] != true
            redirect('/error')
        end
    end
end

get('/') do
    slim(:"Shared/index")
end

get('/comrades') do
    ourhistory = fetch_our_history(params)
    slim(:"Shared/comrades", locals:{
        history: ourhistory,
    })
end

post('/login') do
    response = login(params)
    if response[:error]
        response[:message]
    else
        session[:loggedin] = true
        session[:user_id] = response[:data]
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
        session[:loggedin] = true
        session[:user_id] = id
        session[:name] = params["name"]
        redirect("/profile/#{id}")
    end
end

get('/profile/:id') do
    personalhistory = fetch_history(params)
    slim(:'Profile/profile', locals:{
        history: personalhistory,
    })
end

post('/save_math')  do
    response = addhistory(params)
    if response[:error]
        return response[:message]
    else
        return response[:message]
    end
    redirect("/")
end

post("/profile/:id/delete") do
    delete_user(params)
    redirect("/")
end