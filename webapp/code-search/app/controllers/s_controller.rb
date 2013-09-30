require 'net/http'

class SController
    HOST = '127.0.0.1'
    PORT = '8983'
    CORE = 'code-search'
    
    def self.search(words)
        uri = getURI
        params = {:q => words, :wt => 'json'}
        uri.query = URI.encode_www_form(params)
        ActiveSupport::JSON.decode(Net::HTTP.get(uri))
    end

    def self.getURI
        URI('http://' + HOST + ':' + PORT + '/solr/' + CORE + '/select')
    end
end
