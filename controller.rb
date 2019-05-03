require 'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'json'
require_relative './model.rb'
enable :sessions

un_secure_routes = ['/','/create']

before do
    if session[:history] == nil
        session[:history] = []
    end
end

# before do
#     unless un_secure_routes.include? request.path()
#         if session[:loggedin] != true
#             redirect('/error')
#         end
#     end
# end

get('/') do
    slim(:"Shared/index")
end

get('/comrades') do
    ourhistory = fetch_our_history(params)
    likes = fetch_likes()
    slim(:"Shared/comrades", locals:{
        history: ourhistory,
        likes: likes,
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

post("/profile/history/:calcid/delete") do
    delete_calc(params)
    id=session[:user_id]
    redirect("/profile/#{id}")
end

post("/logout") do
    session.destroy
    redirect('/')
end

post('/like') do
    like(params)
    redirect('/comrades')
end