get '/' do
  # render home page
  @users = User.all
  erb :index
end

#----------- SESSIONS -----------

get '/sessions/new' do
  # render sign-in page
  @email = nil
  erb :sign_in
end

get '/sessions/:id' do
  @user = User.find(params[:id])
  erb :user
end

get '/add_skills/:id' do
  @user = User.find(params[:id])
  erb :add_skills
end

post '/sessions' do
  # sign-in
  @email = params[:email]
  user = User.authenticate(@email, params[:password])
  if user
    # successfully authenticated; set up session and redirect
    session[:user_id] = user.id
    redirect "/sessions/#{user.id}"
  else
    # an error occurred, re-render the sign-in form, displaying an error
    @error = "Invalid email or password."
    erb :sign_in
  end
end

delete '/sessions/:id' do
  # sign-out -- invoked via AJAX
  return 401 unless params[:id].to_i == session[:user_id].to_i
  session.clear
  200
end


#----------- USERS -----------

get '/users/new' do
  # render sign-up page
  @user = User.new
  erb :sign_up
end

post '/users' do
  # sign-up
  @user = User.new params[:user]
  if @user.save
    # successfully created new account; set up the session and redirect
    session[:user_id] = @user.id
    redirect '/'
  else
    # an error occurred, re-render the sign-up form, displaying errors
    erb :sign_up
  end
end

post '/add_skills/:id' do
  p params
  @user = User.find(params[:id])
  @skill = Skill.find_or_create_by(name: params[:skill_name], context: params[:skill_context])
  p @skill
  if @skill
    @user.proficiencies << Proficiency.create(skill_id: @skill.id, user_id: @user.id, formal: params[:formal])
    redirect to ("/sessions/#{@user.id}")
  else
    redirect to ('/oops')
  end
end

