require 'net/http'
require 'nokogiri'
require 'openssl'
require 'socket'
require 'json'
require 'active_record'
gem 'pg'

# Estabelece conexão com o banco de dados PostgreSQL. É importante garantir a segurança das credenciais de acesso.
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'my_database_development',
  pool: 5,
  timeout: 5000,
  username: 'postgres',
  password: '' # A senha está vazia aqui, considere usar uma senha segura.
)

# Definição da classe Profile que herda de ActiveRecord::Base, para interagir com a tabela de perfis no banco de dados.
class Profile < ActiveRecord::Base
  attr_accessible :bio, :imagem, :nome, :status, :tinder_cod
end

# Comentário: A linha abaixo desativa a verificação de SSL, o que pode ser uma vulnerabilidade de segurança.
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Inicialização de variáveis para contar a quantidade de likes, pass e matches.
numero_likes = 0
numero_pass = 0
numero_match = 0

# Token de autenticação utilizado nas requisições à API do Tinder.
AuthToken = '455457af-2dbb-464d-b69f-60a9af6d6a2a'

# Bloco begin para iniciar o processo e lidar com exceções.
begin
  j = 0
  ciclos = 20000 # Número de ciclos definido para o loop. Considere o impacto na API e no sistema.

  # Loop principal que controla a execução dos ciclos.
  while j < ciclos do
    ssl_context = OpenSSL::SSL::SSLContext.new
    tcp_client = TCPSocket.new 'api.gotinder.com', 443
    ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context
    ssl_client.connect

    # A URI abaixo é um exemplo de call de like, que está comentado.
    # uri = URI.parse("https://api.gotinder.com/like/541f603bcec9e97a14dd8742/")

    # URI para obter uma lista de perfis recomendados do Tinder.
    uri = URI.parse("https://api.gotinder.com/user/recs")
    http = Net::HTTP.new(uri.host, uri.port)

    # Configuração necessária para a chamada SSL.
    http.use_ssl = true

    # Configuração de timeout para evitar problemas de longa espera na resposta.
    http.read_timeout = 900

    # Desativação da verificação de SSL. Esta prática não é recomendada por razões de segurança.
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Cabeçalhos da requisição HTTP. Estes cabeçalhos são específicos para interagir com a API do Tinder.
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {
        'platform' =>'android',
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
        'Content-Length' =>'12'
    })

    # Envio de dados na requisição.
    request.set_form_data({"limit" => "40" })

    # Execução da requisição e obtenção da resposta.
    response = http.request(request)

    # Processamento da resposta JSON.
    resposta_json = JSON.parse(response.body)

    # Verifica se a chave "results" está presente na resposta. Caso contrário, espera e tenta novamente.
    unless resposta_json.has_key?("results") 
        sleep 60
        response = http.request(request)
        resposta_json = JSON.parse(response.body)
    end

    # Contagem do número de perfis obtidos na resposta.
    numero_profiles = resposta_json.fetch("results").count

    i = 0

    # Log dos perfis encontrados.
    puts 'Profiles encontrados: ' + numero_profiles.to_s

    # Loop para processar cada perfil individualmente.
    while i < numero_profiles do
        # Decisão aleatória entre 'like' e 'pass'.
        acao = ["pass", "pass","like","like","like","like","like","like"].sample

        # Log da ação escolhida.
        puts acao 

        # Obtém o ID do perfil atual.
        gata = resposta_json.fetch("results")[i].fetch("_id")

        # Construção da URI para a ação de 'like' ou 'pass'.
        url_call = "https://api.gotinder.com/#{acao}/#{gata}/"
        uri = URI.parse(url_call)

        # Logs de progresso.
        puts "cheguei aqui  - 3"

        # Configuração da conexão HTTP para a ação específica.
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        # Mais logs de progresso.
        puts "cheguei aqui  - 2"

        # Cabeçalhos para a requisição de 'like' ou 'pass'.
        request = Net::HTTP::Get.new(uri.request_uri, initheader = {
            'platform' =>'android',
            'User-Agent' =>'Tinder Android Version 3.3.2',
            'X-Auth-Token' => AuthToken,
            'os-version' =>'19',
            'app-version' =>'763',
            'Host' =>'api.gotinder.com',
            'Connection' =>'Keep-Alive',
            'Accept-Encoding' =>'gzip'
        })

        # Execução da requisição e obtenção da resposta.
        response2 = http.request(request)

        # Continuação do código na próxima mensagem...
        # Se a ação for 'like', processa as informações do perfil.
        if acao == 'like'
            puts 'Like em: ' + resposta_json.fetch("results")[i].fetch("name")
            puts resposta_json.fetch("results")[i].fetch("bio")
            puts ''
            puts "cheguei aqui 1"
            puts "cheguei aqui 2"
            puts 'Ja deu match ?: Nao'
            puts "cheguei aqui 3"
            puts 'Deu Match'
            puts "cheguei aqui 4"
            puts ''
            puts response2.inspect
            puts response2.body.inspect

            numero_likes += 1

            # Criação e salvamento de um novo perfil no banco de dados.
            @profile = Profile.new
            @profile.tinder_cod = gata
            @profile.nome = resposta_json.fetch("results")[i].fetch("name")
            @profile.bio = resposta_json.fetch("results")[i].fetch("bio")
            @profile.imagem = resposta_json.fetch("results")[i].fetch("photos")[0].fetch("processedFiles")[0].fetch("url")
            @profile.status = acao
            @profile.save
        end

        # Se a ação for 'pass', processa as informações do perfil.
        if acao == 'pass'
            puts 'Nao dei like em : ' + resposta_json.fetch("results")[i].fetch("name")
            puts resposta_json.fetch("results")[i].fetch("bio")
            puts ''
            puts response2.body

            numero_pass += 1

            # Criação e salvamento de um novo perfil no banco de dados.
            @profile = Profile.new
            @profile.tinder_cod = gata
            @profile.nome = resposta_json.fetch("results")[i].fetch("name")
            @profile.bio = resposta_json.fetch("results")[i].fetch("bio")
            @profile.imagem = resposta_json.fetch("results")[i].fetch("photos")[0].fetch("processedFiles")[0].fetch("url")
            @profile.status = acao
            @profile.save
        end

        # Log após processar cada perfil.
        puts '================================= '
        sleep 4
        i += 1
    end

    # Log parcial após cada ciclo.
    puts '-------PARCIAL------------'
    puts '------Numero de Likes: ' + numero_likes.to_s + '-----------'
    puts '------Numero de Pass: ' + numero_pass.to_s + '-----------'
    puts '------Numero de Matches: '+ numero_match.to_s + '-----------'
    puts '--------------------------'

    j += 1  
end

# Log final após todos os ciclos.
puts '-------FINAL------------'
puts '------Numero de Likes: ' + numero_likes.to_s + '-----------'
puts '------Numero de Pass: ' + numero_pass.to_s + '-----------'
puts '------Numero de Matches: '+ numero_match.to_s + '-----------'
puts '--------------------------'

# Tratamento de exceções genéricas.
rescue Exception => e  
    puts "resuing..."
    puts e.message  
    puts e.backtrace.inspect 
    puts "resuing...more..."
    sleep 600
    retry
end
#logger.debug "Person2"
