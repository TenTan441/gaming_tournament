require 'net/http'
require 'uri'
require 'json'


module ChallongeapisHelper
  
  def get_challonge_api(hash, url)
    #get_body_json = JSON.pretty_generate(hash)
    uri = URI("https://api.challonge.com/v1/tournaments#{url}.json#{"?" + URI.encode_www_form(hash) unless hash.blank?}")
    #uri.query = URI.encode_www_form(hash)
    req = Net::HTTP::Get.new(uri)
    #req.body = get_body_json
    req.basic_auth(Challonge::API.username, Challonge::API.key)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }
    access_token = nil
    
    if res.is_a?(Net::HTTPSuccess)
      access_token = JSON.parse(res.body)
    else
      flash[:danger] = "情報取得に失敗しました。管理者へ問い合わせてください。"
    end
    
    return access_token
  end
  
  def post_challonge_api(hash, url)
    post_body_json = JSON.pretty_generate(hash)
    uri = URI("https://api.challonge.com/v1/tournaments#{url}.json")
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = req['Accept'] = 'application/json'
    #req['Authorization'] = 'bearer ' + access_token
    req.body = post_body_json
    req.basic_auth(Challonge::API.username, Challonge::API.key)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }

    access_token = nil
    bool = false
    if res.is_a?(Net::HTTPSuccess)
      #access_token = JSON.pretty_generate(JSON.parse(res.body))
      bool = true
    else
      #abort "call api failed: body=" + res.body
      flash[:danger] = "情報送信に失敗しました。管理者へ問い合わせてください。"
    end
    
    if res.body
      access_token = JSON.parse(res.body)
    end
    
    return bool, access_token
  end
  
  def put_challonge_api(hash, url)
    put_body_json = JSON.pretty_generate(hash)
    uri = URI("https://api.challonge.com/v1/tournaments#{url}.json")
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = req['Accept'] = 'application/json'
    #req['Authorization'] = 'bearer ' + access_token
    req.body = put_body_json
    req.basic_auth(Challonge::API.username, Challonge::API.key)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }

    access_token = nil
    bool = false
    if res.is_a?(Net::HTTPSuccess)
      bool = true
    else
      flash[:danger] = "情報送信に失敗しました。管理者へ問い合わせてください。"
    end
    
    if res.body
      access_token = JSON.parse(res.body)
    end
    
    return bool, access_token
  end
  
  def delete_challonge_api(hash, url)
    put_body_json = JSON.pretty_generate(hash)
    uri = URI("https://api.challonge.com/v1/tournaments#{url}.json#{"?" + URI.encode_www_form(hash) unless hash.blank?}")
    req = Net::HTTP::Delete.new(uri)
    req['Content-Type'] = req['Accept'] = 'application/json'
    #req['Authorization'] = 'bearer ' + access_token
    req.body = put_body_json
    req.basic_auth(Challonge::API.username, Challonge::API.key)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(req)
    }

    access_token = nil
    bool = false
    if res.is_a?(Net::HTTPSuccess)
      #access_token = JSON.pretty_generate(JSON.parse(res.body))
      bool = true
    else
      #abort "call api failed: body=" + res.body
      flash[:danger] = "情報送信に失敗しました。管理者へ問い合わせてください。"
    end
    
    if res.body
      access_token = JSON.parse(res.body)
    end
    
    return bool, access_token
  end
end
