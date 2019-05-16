require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'json'
require 'sinatra/flash'
require_relative './model.rb'
include Model
enable :sessions
set :show_exceptions, :after_handler
un_secure_routes = ['/','/create','/login','/error']



before do
    if session[:history] == nil
        session[:history] = []
    end
end

before do
    unless un_secure_routes.include? request.path()
        if session[:loggedin] != true
            redirect('/error')
        end
    end
end

get('/') do
    slim(:"Shared/index")
end

get('/comrades') do
    ourhistory = Calculations.fetch_our_history(params)
    likes = Likes.fetch_likes()
    slim(:"Shared/comrades", locals:{
        history: ourhistory,
        likes: likes,
    })
end

get('/profile') do
    id = session[:user_id]
    personalhistory = Calculations.fetch_history(id)
    slim(:'Profile/profile', locals:{
        history: personalhistory,
    })
end

get("/error") do
    slim(:"Error/forbidden")
end

post('/login') do
    response = Users.login(params)
    if response[:error]
        flash[:error] = response[:message]
        redirect back
    else
        session[:loggedin] = true
        session[:user_id] = response[:data]
        session[:name] = params["name"]
        redirect("/profile")
    end
end

post('/create') do
    response = Users.create(params)
    id = response[:data]
    if response[:error]
        flash[:error] = response[:message]
        redirect back
    else
        session[:loggedin] = true
        session[:user_id] = id
        session[:name] = params["name"]
        redirect("/profile")
    end
end


post('/save_math')  do
    id = session[:user_id] 
    response = Calculations.addhistory(params, id)
    if response[:error]
        flash[:error] = response[:message]
        redirect back
    else
        flash[:error] = response[:message]
        redirect back
    end
end

post("/profile/delete") do
    Users.delete_user(params)
    redirect("/")
end

post("/profile/history/:calcid/delete") do
    Calculations.delete_calc(params)
    redirect("/profile")
end

post("/logout") do
    session.destroy
    redirect('/')
end

post('/like') do
    id = session[:user_id]
    Likes.like(params,id)
    redirect('/comrades')
end

