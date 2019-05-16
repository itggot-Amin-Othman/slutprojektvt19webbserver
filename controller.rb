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

# Display Landing Page
#
get('/') do
    slim(:"Shared/index")
end

# Display list of users history
#
# @see Model#Calculations#fetch_our_history
# @see Model#Likes#fetch_likes
get('/comrades') do
    ourhistory = Calculations.fetch_our_history()
    likes = Likes.fetch_likes()
    slim(:"Shared/comrades", locals:{
        history: ourhistory,
        likes: likes,
    })
end

# Display the users profile
#
# @see Model#Calculations#fetch_history
get('/profile') do
    id = session[:user_id]
    personalhistory = Calculations.fetch_history(id)
    slim(:'Profile/profile', locals:{
        history: personalhistory,
    })
end

# Display an error page
#
get("/error") do
    slim(:"Error/forbidden")
end

# Attempts login and updates the session
#
# @param [String] name, The username
# @param [String] pass, The password
#
# @see Model#Users#login
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

# Attempts create an account and login
#
# @param [String] name, The username
# @param [String] pass, The password
# @param [String] pass2, The repeated password
#
# @see Model#Users#create
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

# Attempts to save history to the database
#
# @param [String] calculation, The calculations to be saved
#
# @see Model#Calculations#add_history
post('/save_math')  do
    id = session[:user_id] 
    response = Calculations.add_history(params, id)
    if response[:error]
        flash[:error] = response[:message]
        redirect back
    else
        flash[:error] = response[:message]
        redirect back
    end
end

# Attempts to delete user from the database
#
# @param [String] id, The logged in users id
#
# @see Model#Users#delete_user
post("/profile/delete") do
    Users.delete_user(params)
    redirect("/")
end

# Attempts to delete a calculation from the database
#
# @param [String] calc_id, The calculations id
#
# @see Model#Calculations#delete_calc
post("/profile/history/:calcid/delete") do
    Calculations.delete_calc(params)
    redirect("/profile")
end

# Logs out user and destroys session
#
post("/logout") do
    session.destroy
    redirect('/')
end

# Uppdates amount of likes
#
# @param [String] calc_id, The calculations id
# @param [String] id, The calculations creators id
#
# @see Model#Likes#like
post('/like') do
    id = session[:user_id]
    Likes.like(params,id)
    redirect('/comrades')
end

