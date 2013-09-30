#!/usr/bin/ruby

=begin
关于grit的API使用,参考 https://github.com/mojombo/grit
=end

require 'rubygems'
require 'grit'
require 'net/http'
require 'json'

class Importer
    attr_reader :root, :repo
    
    include Grit

    def initialize(repo_path)
        @repo = repo_path
        @root = Repo.new(repo_path).tree
    end

    def traverse(tree, path='REPOSITORY')
        tree.contents.each do |c|
            case c
                when Grit::Tree
                    tmp_path = path + '/' + c.name
                    traverse(c, tmp_path)
                when Grit::Blob
                    file_path = path + '/' + c.name
                    mime = c.mime_type.scan(/image/)
                    #puts file_path unless mime.empty?
                    Document.new(c.id, file_path, c.data).index if mime.empty?
            end
        end
    end
end

class Document

    HOST = '192.168.2.150'
    PORT = 8983
    PATH = '/solr/code-search/update/json'
    HEADERS = {
        'Content-type' => 'application/json'
    }
    @@http = Net::HTTP.new(HOST, PORT)

    def initialize(hash, file, code)
        @hash = hash
        @file = file
        @code = code
    end

    def index
        data = to_json
        return if data.nil?
        resp = @@http.post(PATH, data, HEADERS)
        puts 'add index failed' + "\n" + resp.body unless resp.code == '200'
    end

    def self.deleteAll!
        query = {
            :delete => {
                :query => '*:*',
                :commitWithin => 500
            }
        }
        resp = @@http.post(PATH, query.to_json, HEADERS)
        puts 'delete all failed!' + "\n" + resp.body unless resp.code == '200'
    end

    def to_json
        begin
            {
                :add => {
                    :doc => {
                        :hash => @hash,
                        :file => @file,
                        :code => @code,
                    },
                    :overwrite => true,
                    :commitWithin => 1000
                }
             }.to_json
        rescue
            nil
        end
    end
end

#Document.new('abcd', 'file345', 'second code').index
#Document.deleteAll!
repo_path = '/home/sankuai/repository/www'
importer = Importer::new(repo_path)
importer.traverse(importer.root, importer.repo)
