module Model
        # Establishes a connection to the database
        #
        # @return [SQLite3::Database] a connection with Hash 
        def self.connect
            db = SQLite3::Database.new('db/slutarbdb.db')
            db.results_as_hash = true
            return db
        end

        # Establishes a connection to the database
        #
        # @return [SQLite3::Database] a connection without Hash 
        def self.connect_non_hash
            db = SQLite3::Database.new('db/slutarbdb.db')
            return db
        end

    module Users
        # Attempts to find a user
        #
        # @param [Hash] params form data
        # @option params [String] name, The username
        # @option params [String] pass, The password
        #
        # @return [Hash]
        #   * :error [Boolean] whether an error occured
        #   * :message [String] the error message if an error occured
        #   * :data [Integer] The user's ID if the user was created
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

        # Attempts to create a new user
        #
        # @param [Hash] params form data
        # @option params [String] name, The username
        # @option params [String] pass, The password
        # @option params [String] pass2, The repeated password
        #
        # @return [Hash]
        #   * :error [Boolean] whether an error occured
        #   * :message [String] the error message if an error occured
        #   * :data [Integer] The user's ID if the user was created
        def self.create(params)
            if params["pass"] == params["pass2"]
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
            else
                return {
                    error: true,
                    message: "Passwords do not match"
                }
            end
        end

        # Attempts to delete a row from the users table
        #
        # @param [String] id, The users ID
        def self.delete_user(params)
            db = Model::connect()
            db.execute("DELETE FROM users WHERE UserId=(?) ",params['id'])
        end
    end

    module Calculations
        # Attempts to insert a new row in the articles table
        #
        # @param [Hash] params form data
        # @option params [String] title The title of the article
        # @option params [String] content The content of the article
        #
        # @return [Hash]
        #   * :error [Boolean] whether an error occured
        #   * :message [String] the error message
        def self.add_history(params,id)
            db = Model::connect()
            calculation = params["history"]
            db.execute("INSERT INTO calculations(UserId,Calculation) VALUES ((?),(?))",id ,calculation.first)
            
            return {
                error: false,
                message: "Calculation saved!"
                }
        end
        # Attempts to delete a row from the calculations table
        #
        # @param [String] calc_id, The calculations ID
        def self.delete_calc(params)
            db = Model::connect()
            db.execute("DELETE FROM calculations WHERE CalcId=(?)", params['calcid'])
        end

        # Attempts to fetch rows from the calculations table
        # 
        # @param [String] id, The users ID
        #
        # @return [Array] containing the data of the users calculations
        def self.fetch_history(id)
            db = Model::connect()
            return db.execute("SELECT calculations.Calculation, calculations.CalcId FROM calculations INNER JOIN users ON calculations.UserId=users.UserId WHERE users.userid = (?)", id)
        end

        # Attempts to fetch all rows from the calculations table
        #
        # @return [Array] containing the data of all calculations
        def self.fetch_our_history()
            db = Model::connect()
            return db.execute("SELECT calculations.Calculation, calculations.CalcId, users.Username FROM calculations INNER JOIN users ON calculations.UserId=users.UserId")
        end 
    end

    module Likes

        # Attempts to fetch the number of likes for all calulations
        #
        # @return [Array] Amount of likes connected to each calculation
        def self.fetch_likes()
            db = Model::connect()
            return db.execute("SELECT * FROM likes")
        end

        # Attempts to update a row in the likes table
        #
        # @param [Integer] article_id The article's ID
        # @param [String] id, The users ID
        #
        # @return [Hash]
        #   * :error [Boolean] whether an error occured
        #   * :message [String] the error message
        def self.like(params,id)
            db = Model::connect_non_hash()
            previously_liked=db.execute("SELECT calcid FROM likes WHERE userid=(?)", id)
            previously_liked = previously_liked.flatten
            if previously_liked.include? params['calcid'].to_i
                return {
                    error: true,
                    message: "You cant like twice you dingus!"
                    }
            else
                db.execute("INSERT INTO likes(UserId,CalcId) VALUES ((?),(?))",id, params['calcid'])
            end
        end
    end
end