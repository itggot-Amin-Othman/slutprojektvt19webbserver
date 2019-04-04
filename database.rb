

post('/login') do
    db = SQLite3::Database.new('slutarbdb.db')
    db.results_as_hash = true
    result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", params["name"])
    if result == []
        redirect('/')
    end
    encrypted_pass = result[0]["Password"]
    if BCrypt::Password.new(encrypted_pass) == params["pass"]
        session[:loggedin] = true
        session[:user_id] = result[0]["UserId"]
        session[:name] = params["name"]
        redirect('/profil')
    else
        redirect('/')
    end
end