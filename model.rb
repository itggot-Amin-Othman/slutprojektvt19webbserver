def connect
    db = SQLite3::Database.new('db/slutarbdb.db')
    db.results_as_hash = true
    return db
end

def login(params)
    db = connect()
    result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", params["name"])
    if result == []
        return {
            error: true,
            message: "This person does not exist"
        }
    end
    encrypted_pass = result[0]["Password"]
    if BCrypt::Password.new(encrypted_pass) == params["pass"]
        id = db.execute("SELECT UserId FROM users WHERE Username =(?)", params["name"])
        return {
            error: false,
            data: id[0][0]
        }
    else
        return {
            error: true,
            message: "This password is incorrect"
        }

    end
end

def create(params)
    db = connect()
    name = params["name"]
    password = BCrypt::Password.create(params["pass"])
    result = db.execute("SELECT UserId FROM users WHERE Username =(?)", params["name"])
    if result != []
        return {
            error: true,
            message: "Username taken"
        }
    else
        db.execute("INSERT INTO users(Username,Password) VALUES((?),(?))",name,password) 
        id = db.execute("SELECT UserId FROM users WHERE Username =(?)", params["name"])
        return {
            error: false,
            data: id[0][0]
        }

    end
end

def addhistory(params)
    db = connect()
    calculation = params["history"]
    id = session[:user_id]
    db.execute("INSERT INTO calculations(UserId,Calculation) VALUES ((?),(?))", id,calculation.first)
    return {
        error: false,
        message: "Calculation saved!"
        }
end

def delete_user(params)
    db = connect()
    db.execute("DELETE FROM users WHERE UserId=(?) ",params['id'])
end

def fetch_history(params)
    db = connect()
    return db.execute("SELECT calculations.Calculation FROM calculations INNER JOIN users ON calculations.UserId=users.UserId WHERE users.userid = (?)", params['id'])
end

def fetch_our_history(params)
    db = connect()
    return db.execute("SELECT calculations.Calculation, users.Username FROM calculations INNER JOIN users ON calculations.UserId=users.UserId")
end