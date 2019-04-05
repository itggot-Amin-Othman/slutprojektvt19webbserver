def connect
    db = SQLite3::Database.new('slutarbdb.db')
    db.results_as_hash = true
    return db
end

def login(params)
    db = connect
    result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", params["name"])
    if result == []
        redirect('/')
    end
    encrypted_pass = result[0]["Password"]
    if BCrypt::Password.new(encrypted_pass) == params["pass"]
        return true
        session[:loggedin] = true
        session[:user_id] = result[0]["UserId"]
        session[:name] = params["name"]
        redirect('/profile')
    else
        return false
        redirect('/')
    end
end

def create(params)
    db = connect()
    name = params["name"]
    password = BCrypt::Password.create(params["pass"])
    result = db.execute("SELECT UserId FROM users WHERE Username =(?)", params["name"])
    if result.length > 0
        return {
            error: true,
            message: "User already exists"
        }
    else
        db.execute("INSERT INTO users(Username,Password) VALUES((?),(?))",name,password) 
        return {
            error: false,
            data: 
        }
    end
    
    # redirect('/')
end