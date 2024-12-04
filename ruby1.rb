require 'net/http'
require 'nokogiri'
require 'openssl'
require 'socket'
require 'json'
require 'active_record'
gem 'pg'


#ActiveRecord::Base.establish_connection(
#  adapter: 'postgresql',
#  database: 'my_database_development',
#  pool: 5,
#  timeout: 5000,
#  username: 'postgres',
#  passsword: 12345 
#  )

class Profile < ActiveRecord::Base
  attr_accessible :bio, :imagem, :nome, :status, :tinder_cod
end

#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE	


	numero_likes = 0
	numero_pass = 0
	numero_match = 0

	AuthToken = '69a7c6de-ad9d-4f69-89fe-46c8d48d4594'

	begin

	j = 0
	ciclos = 20000

	while j < ciclos do

		ssl_context = OpenSSL::SSL::SSLContext.new
		tcp_client = TCPSocket.new 'api.gotinder.com', 443
		ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context
		ssl_client.connect

		#Call de like
		#uri = URI.parse("https://api.gotinder.com/like/541f603bcec9e97a14dd8742/")

		#Call de retornar lista mulheres
		uri = URI.parse("https://api.gotinder.com/user/recs")

	  	http = Net::HTTP.new(uri.host, uri.port)

	  	#para call ssl precisa disso
	  	http.use_ssl = true

	  	#Coloquei isso aqui pq estava dando problema rbulf_fill - http://stackoverflow.com/questions/10011387/rescue-in-rbuf-fill-timeouterror-timeouterror
	  	http.read_timeout = 900

	  	#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

	  	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		request = Net::HTTP::Post.new(uri.request_uri, initheader = {'platform' =>'android',
			'If-None-Match' =>'-281726152',
			'If-Modified-Since' =>'Wed, 05 Nov 2014 17:03:47 GMT+00:00',
			'User-Agent' =>'Tinder Android Version 3.3.2',
			'X-Auth-Token' => AuthToken,
			'os-version' =>'19',
			'app-version' =>'763',
			'Content-Type' =>'application/json; charset=utf-8',
			'Host' =>'api.gotinder.com',
			'Connection' =>'Keep-Alive',
			'Accept-Encoding' =>'gzip',
			'Content-Length' =>'12'})



		request.set_form_data({"limit" => "40" })
		
		#logger.debug request.inspect



		response = http.request(request)

		resposta_json = JSON.parse(response.body)

		#puts resposta_json

		unless resposta_json.has_key?("results") 
			sleep 60
			response = http.request(request)
			resposta_json = JSON.parse(response.body)
			#puts resposta_json
		end

		numero_profiles = resposta_json.fetch("results").count

		#gata = JSON.parse(response.body).fetch("results")[0].fetch("_id")

		i = 0

		puts 'Profiles encontrados: ' + numero_profiles.to_s

		while i < numero_profiles do
		
			
			
							acao = ["pass", "pass","like","like","like","like","like","like"].sample

							puts acao 

							gata = resposta_json.fetch("results")[i].fetch("_id")

							url_call = "https://api.gotinder.com/#{acao}/#{gata}/"
							uri = URI.parse(url_call)

							puts "cheguei aqui  - 3"
			

						  	http = Net::HTTP.new(uri.host, uri.port)

						  	http.use_ssl = true
						  	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

						  	puts "cheguei aqui  - 2"

							request = Net::HTTP::Get.new(uri.request_uri, initheader = {'platform' =>'android',
								'User-Agent' =>'Tinder Android Version 3.3.2',
								'X-Auth-Token' => AuthToken,
								'os-version' =>'19',
								'app-version' =>'763',
								'Host' =>'api.gotinder.com',
								'Connection' =>'Keep-Alive',
								'Accept-Encoding' =>'gzip'})

							#response2 é a resposta do like, resposta_json é a resposta da lista de profiles
							puts "cheguei aqui  - 1"
							response2 = http.request(request)
							puts "cheguei aqui   0"

						if acao == 'like'

							puts 'Like em: ' + resposta_json.fetch("results")[i].fetch("name")
							puts resposta_json.fetch("results")[i].fetch("bio")

							puts''

							puts "cheguei aqui 1"
							
							#if JSON.parse(response2.body).fetch("match") == false
							
							puts "cheguei aqui 2"

								puts'Ja deu match ?: Nao'
							#else

								puts "cheguei aqui 3"

								puts'Deu Match'
								#numero_match +=1
							#end
							puts "cheguei aqui 4"
							puts''
							#Parece que estou com um probleminha aqui, ele retorna um json mt pequeno menor q 2 x 8bits
							puts response2.inspect
							puts response2.body.inspect

							numero_likes +=1

							#@profile = Profile.new

            				#@profile.tinder_cod = gata
            				#@profile.nome = resposta_json.fetch("results")[i].fetch("name")
            				#@profile.bio = resposta_json.fetch("results")[i].fetch("bio")
            				#@profile.imagem = resposta_json.fetch("results")[i].fetch("photos")[0].fetch("processedFiles")[0].fetch("url")
            				#@profile.status = acao

            				#@profile.save

						end


						if acao == 'pass'

							puts 'Nao dei like em : ' + resposta_json.fetch("results")[i].fetch("name")
							puts resposta_json.fetch("results")[i].fetch("bio")

							puts''
							puts response2.body

							numero_pass +=1

							#@profile = Profile.new

            				#@profile.tinder_cod = gata
            				#@profile.nome = resposta_json.fetch("results")[i].fetch("name")
            				#@profile.bio = resposta_json.fetch("results")[i].fetch("bio")
            				#@profile.imagem = resposta_json.fetch("results")[i].fetch("photos")[0].fetch("processedFiles")[0].fetch("url")
            				#@profile.status = acao

            				#@profile.save

						end

			puts '================================= '

			sleep 4
	   		i +=1
	   		
		end

	puts '-------PARCIAL------------'
	puts '------Numero de Likes: ' + numero_likes.to_s + '-----------'
	puts '------Numero de Pass: ' + numero_pass.to_s + '-----------'
	puts '------Numero de Matches: '+ numero_match.to_s + '-----------'
	puts '--------------------------'

	j +=1	
end

	puts '-------FINAL------------'
	puts '------Numero de Likes: ' + numero_likes.to_s + '-----------'
	puts '------Numero de Pass: ' + numero_pass.to_s + '-----------'
	puts '------Numero de Matches: '+ numero_match.to_s + '-----------'
	puts '--------------------------'

	
rescue Exception => e  
	puts "resuing..."
  	puts e.message  
  	puts e.backtrace.inspect 
  	puts "resuing...more..."
	sleep 600
	retry
end
	#logger.debug "Person2"


