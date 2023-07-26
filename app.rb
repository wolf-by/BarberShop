#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

configure do
	db = SQLite3::Database.new 'barbershop.db'
	db.execute 'CREATE TABLE IF NOT EXISTS
	"Users"
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"username" TEXT,
		"phone" TEXT,
		"datestamp" TEXT,
		"barber" TEXT,
		"color" TEXT 
	)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School - Labs 24</a>"			
end

get '/about' do 
	erb :about
end

get '/contacts' do 
	erb :contacts
end

get '/visit' do
	erb :visit
end

post '/visit' do 
	@username = params[:username]
	@phone = params[:phone]
	@barber = params[:barber]
	@datetime = params[:datetime]
 	@color = params[:color]

 	hh = { :username => 'Введите имя',
 		   :phone => 'Введите телефон',
 		   :datetime => 'Введите дату и время'
 	}

 	hh.each do |key, value|
 		if params[key] == ''
 			@error = hh[key]
 			return erb :visit
 		end
 	end	

 	#sqlite3
 	db = SQLite3::Database.new 'barbershop.db'
 	db.execute 'insert into
 		Users
 		(
 			username,
 			phone,
 			datestamp,
 			barber,
 			color
 		) 
 		values ( ?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]

	f = File.open './public/users.txt', 'a'
	f.write "Клиент: #{@username},
			 Телефон: #{@phone},
			 Парикмахер: #{@barber},
			 Дата и время: #{@datetime},
			 Цвет краски: #{@color}.\n"
	f.close

	erb :visit
end

post '/contacts' do
	@email = params[:email]
	@message = params[:message]

	hh2 = { :email => 'Введите email',
			:message => 'Введите сообщение'
	}

	hh2.each do |key, value|
		if params[key] == ''
			@error = hh2[key]
			return erb :contacts
		end	
	end	
	
	f = File.open './public/contacts.txt', 'a'
	f.write "Email клиент: #{@email}, Сообщение: #{@message}\n"
	f.close

	#отправка данных страницы contacts на почту 
	Pony.mail ({

	:to => '@gmail.com', #адрес куда отправить 
	:subject => 'Barber shop',
	:body => "Email клиент: #{@email}, Сообщение: #{@message}\n",
	:via => :smtp,
	:via_options => {
		:address => 'smtp.gmail.com',
		:port => '587',
		:user_name => '@gmail.com', #ваша почта на gmail, с нее отправка
		:password => '', #требуется в аккаунте gmail создать - Пароль приложений
		:authentication => :plain, 
		:domain => 'gmail.com'
	} 
})

	erb "Данные отправлены" 
end

get '/showusers' do

	#sqlite3 db read
 	db = get_db
 	
	@results = db.execute 'select * from Users order by id'


  erb :showusers
end