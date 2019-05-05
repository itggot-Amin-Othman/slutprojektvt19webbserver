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

def delete_calc(params)
    db = connect()
    db.execute("DELETE FROM calculations WHERE CalcId=(?)", params['calcid'])
end

def fetch_history(params)
    db = connect()
    return db.execute("SELECT calculations.Calculation, calculations.CalcId FROM calculations INNER JOIN users ON calculations.UserId=users.UserId WHERE users.userid = (?)", params['id'])
end

def fetch_our_history(params)
    db = connect()
    return db.execute("SELECT calculations.Calculation, calculations.CalcId, users.Username FROM calculations INNER JOIN users ON calculations.UserId=users.UserId")
end 

def fetch_likes()
    db = connect()
    return db.execute("SELECT * FROM likes")
end

def like(params)
    db = connect()
    previously_liked=db.execute("SELECT likes.calcid FROM likes WHERE userid=(?)", session[:user_id])
    previously_liked = previously_liked.flatten
    if previously_liked.include? params['calcid'].to_i
        return {
            error: true,
            message: "You cant like twice you dingus!"
            }
    else
        db.execute("INSERT INTO likes(UserId,CalcId) VALUES ((?),(?))",session[:user_id], params['calcid'])
    end
end