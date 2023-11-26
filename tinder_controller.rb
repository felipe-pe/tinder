require 'net/http'
require 'nokogiri'
require 'openssl'
require 'socket'

# Classe responsável pela interação com a API do Tinder
class TinderController < ApplicationController

  def index
    # Desativa a verificação de SSL. Isso é uma prática insegura e não recomendada.
    # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  

    # Configuração manual da conexão SSL (código comentado)
    # ssl_context = OpenSSL::SSL::SSLContext.new
    # tcp_client = TCPSocket.new 'api.gotinder.com', 443
    # ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, ssl_context
    # ssl_client.connect

    # URI para realizar a ação de like (código comentado)
    # uri = URI.parse("https://api.gotinder.com/like/541f603bcec9e97a14dd8742/")

    # URI para obter uma lista de recomendações de perfis
    uri = URI.parse("https://api.gotinder.com/user/recs")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Cabeçalhos da requisição HTTP
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'platform' =>'android',
        'If-None-Match' =>'-281726152',
        'If-Modified-Since' =>'Fri, 31 Oct 2014 21:12:52 GMT+00:00',
        'User-Agent' =>'Tinder Android Version 3.3.2',
        'X-Auth-Token' =>'bcb572cf-953d-4843-b0d7-b4f7257e5bc5',
        'os-version' =>'19',
        'app-version' =>'763',
        'Content-Type' =>'application/json; charset=utf-8',
        'Host' =>'api.gotinder.com',
        'Connection' =>'Keep-Alive',
        'Accept-Encoding' =>'gzip',
        'Content-Length' =>'12'})

    # Dados enviados na requisição
    request.set_form_data({"limit" => "40" })
    
    # Envio da requisição e recebimento da resposta
    response = http.request(request)

    # Processamento da resposta para obter dados dos perfis
    @numero_profiles = JSON.parse(response.body).fetch("results").count
    @nome = JSON.parse(response.body).fetch("results")[0].fetch("name")
    @idade = JSON.parse(response.body).fetch("results")[0].fetch("birth_date").to_date
    @foto_url = JSON.parse(response.body).fetch("results")[0].fetch("photos")[0].fetch("processedFiles")[0].fetch("url")
    @bio = JSON.parse(response.body).fetch("results")[0].fetch("bio")
    @gata = JSON.parse(response.body).fetch("results")[0].fetch("_id")

    # Comentários para debug (código comentado)
    # logger.debug request.inspect
    # logger.debug "Person2"
  end

  def like
    # Recebe o ID do perfil como parâmetro para realizar a ação de like
    gata = params[:id]

    # Configuração da URI para a ação de like
    url_call = "https://api.gotinder.com/pass/#{gata}/"
    uri = URI.parse(url_call)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Cabeçalhos da requisição de like
    request = Net::HTTP::Get.new(uri.request_uri, initheader = {'platform' =>'android',
        'User-Agent' =>'Tinder Android Version 3.3.2',
        'X-Auth-Token' =>'bcb572cf-953d-4843-b0d7-b4f7257e5bc5',
        'os-version' =>'19',
        'app-version' =>'763',
        'Host' =>'api.gotinder.com',
        'Connection' =>'Keep-Alive',
        'Accept-Encoding' =>'gzip'})

    # Envio da requisição de like e recebimento da resposta
    response = http.request(request)

    # Renderiza a resposta do like
    render :text => 'Resposta:' + response.body
  end

end
