
API_HOST = "127.0.0.1"
API_PORT = 3003

def start_api_server
  User.create username: 'testuser', password: 'secret'
  Capybara.always_include_port = true
  Capybara.server_port = API_PORT
  visit '/'
end

def api_base_url
  "http://testuser:secret@#{API_HOST}:#{API_PORT}/api/"
end

def api_url(path)
  api_base_url + path
end
