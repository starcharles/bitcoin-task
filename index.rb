require 'net/http'
require 'json'

RPCUSER = "hoge"
RPCPASSWORD = "hoge"
HOST = "127.0.0.1"
PORT = "8332"
EXPLORER = "https://blockchain.info/q/getblockcount"
SLACK_URL = "https://hooks.slack.com/services/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"

def bitcoinRPC(method, param)
  http = Net::HTTP.new(HOST, PORT)
  request = Net::HTTP::Post.new('/')
  request.basic_auth(RPCUSER, RPCPASSWORD)
  request.content_type= 'application/json'
  request.body = {method: method, params: param, id: 'jsonrpc'}.to_json
  JSON.parse(http.request(request).body)["result"]
end

def getExplorerBlockNum
  uri = URI.parse(EXPLORER)
  response = Net::HTTP.get_response(uri)
  response.body.to_i
end

def notifyToSlack(url, diff)
  params = {
    text: "block diff alert! => Diff: #{diff} blocks"
  }

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.start do
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(payload: params.to_json)
    http.request(request)
  end
  p "notified to slack."
end


infoRPC = bitcoinRPC("getblockchaininfo", [])
latestBlockRPC = infoRPC["blocks"]
latestBlockExplorer = getExplorerBlockNum

diff = latestBlockRPC - latestBlockExplorer
p "diff: #{diff}"
if diff >=3 || diff <= -3
  notifyToSlack(SLACK_URL, diff)
end
