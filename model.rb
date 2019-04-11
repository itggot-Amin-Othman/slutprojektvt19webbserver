def connect
    db = SQLite3::Database.new('db/slutarbdb.db')
    db.results_as_hash = true
    return db
end

# def login(params)
#     db = connect()
#     result = db.execute("SELECT Password, UserId FROM users WHERE Username =(?)", params["name"])
#     if result == []
#         return {
#             error: true,
#             message: "This person does not exist"
#         }
#     end
    
#     encrypted_pass = result[0]["Password"]
#     if BCrypt::Password.new(encrypted_pass) == params["pass"]
#         return {
#             error: false,
#             data: result
#         }
#     else
#         return {
#             error: true,
#             message: "This password is incorrect"
#         }

#     end
# end

def create(params)
    db = connect()
    name = params["name"]
    password = BCrypt::Password.create(params["pass"])
    result = db.execute("SELECT UserId FROM users WHERE Username =(?)", params["name"])
    if result == [777]
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