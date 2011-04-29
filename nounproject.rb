require 'sinatra'
require 'nokogiri'
require 'net/http'
require 'haml'
require 'sqlite3'
require 'json'

def get_db
	SQLite3::Database.new( "test.db" )
end
BAD = [334, 360, 368, 512, 642, 645]
ALL = (1..653).to_a - BAD
get "/" do
	@icons = ALL.sort_by {rand()}.take(5).map do |i|
		r=Net::HTTP.get(URI.parse("http://thenounproject.com/modal/#{i}/?svg=true"))
		d=Nokogiri::HTML(r)
		{:num=>i,:text=>d.at_css("h2").text,:svg=>d.at_css("span.svg svg#Layer_1").to_s}
	end
	haml :index
end

post "/save_story" do
	db = get_db
	db.execute("insert into stories ('icons','story') values (?,?)",params[:icons].to_json,params[:story])
	id = db.execute("select last_insert_rowid()")[0][0]
	"Story Saved! you can see it <a href=\"/story/#{id}\">here</a>"
end

get '/story/:id' do
	db = get_db
	@story = db.execute("select * from stories where id = ?",params[:id])[0]
	if @story
		haml :story
	else
		[404,{},"story not found"]
	end
end
get '/stories' do
	"todo"
end
