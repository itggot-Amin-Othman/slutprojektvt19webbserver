module Model
        def self.connect
            db = SQLite3::Database.new('db/slutarbdb.db')
            db.results_as_hash = true
            return db
        end

        def self.connect_non_hash
            db = SQLite3::Database.new('db/slutarbdb.db')
            return db
        end

    module Users
        def self.login(params)
            db = Model::connect()
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

        def self.create(params)
            db = Model::connect()
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

        def self.delete_user(params)
            db = Model::connect()
            db.execute("DELETE FROM users WHERE UserId=(?) ",params['id'])
        end
    end

    module Calculations
        def self.addhistory(params)
            db = Model::connect()
            calculation = params["history"]
            id = session[:user_id]
            db.execute("INSERT INTO calculations(UserId,Calculation) VALUES ((?),(?))", id,calculation.first)
            
            return {
                error: false,
                message: "Calculation saved!"
                }
        end

        def self.delete_calc(params)
            db = Model::connect()
            db.execute("DELETE FROM calculations WHERE CalcId=(?)", params['calcid'])
        end

        def self.fetch_history(params)
            db = Model::connect()
            return db.execute("SELECT calculations.Calculation, calculations.CalcId FROM calculations INNER JOIN users ON calculations.UserId=users.UserId WHERE users.userid = (?)", params['id'])
        end

        def self.fetch_our_history(params)
            db = Model::connect()
            return db.execute("SELECT calculations.Calculation, calculations.CalcId, users.Username FROM calculations INNER JOIN users ON calculations.UserId=users.UserId")
        end 
    end

    module Likes
        def self.fetch_likes()
            db = Model::connect()
            return db.execute("SELECT * FROM likes")
        end

        def self.like(params)
            db = Model::connect_non_hash()
            previously_liked=db.execute("SELECT calcid FROM likes WHERE userid=(?)", session[:user_id])
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
    end
end