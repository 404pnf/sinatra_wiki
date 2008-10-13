%w(rubygems sinatra erb rdiscount thin yaml digest/sha1).each do |lib|
  require lib
end
Dir["lib/**/*"].each do |lib|
  require lib
end

configure do
  @config = YAML::load(File.read('config.yml')).to_hash.each do |k,v|
    set k, v
  end
end

before do
  content_type 'text/html', :charset => 'utf-8'
  @page = Page.new("home") # Default page
end

get '/' do
  @pages = Dir["public/**/*.txt"]
  erb :home
end
get '/:slug' do
  @page = Page.new(params[:slug])
  if @page.is_new
    redirect "/#{@page.name}/edit"
  else
    @content = @page.html
    erb :page
  end
end
get '/:slug/edit' do
  authenticate_or_request_with_http_basic do |user_name, password|
    user_name == Sinatra.options.username && Digest::SHA1.hexdigest(password) == Sinatra.options.password
  end if Sinatra.options.use_auth
  @page = Page.new(params[:slug])
  erb :edit
end
post '/:slug/edit' do
  nice_title = Slugalizer.slugalize(params[:title])
  @page = Page.new(nice_title)
  @page.content = params[:body]
  redirect "/#{nice_title}"
end