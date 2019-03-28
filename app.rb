require 'sinatra'
require 'slim'
enable :sessions

before do
    if session[:answer] == nil
        session[:answer] = []
    end
end

get('/') do
    if session[:answer] != nil
        slim(:calc)
    end
    slim(:calc)
end

post('/calculate') do
    tal1 = params[:tal1].to_f
    tal2 = params[:tal2].to_f
    operator = params[:operator]
    answer = 0
        if tal2 == 0 && operator == "/"
            halt 403
        end
    case operator
    when "+"
        answer = tal1 + tal2
    when "-"
        answer = tal1 - tal2
    when "*"
        answer = tal1 * tal2
    when "/"
        answer = tal1 / tal2
    end
    session[:answer] << "$#{tal1}$ #{operator} $#{tal2}$ = $#{answer}$"
    redirect('/')
end

post('/clear') do
    session[:answer] = nil
    redirect('/')
end

error do
    'What the fuck did you do, it worked fine before you came, now we have a' + env['sinatra.error'].message + 'you fuck.'
end

error 404 do
    redirect('/nope')
end

error 403 do
    redirect('/forbidden')
end

get('/nope') do
    slim(:nope)
end

get('/forbidden') do
    slim(:forbidden)
end

post('/unfuck') do
    redirect('/')
end

