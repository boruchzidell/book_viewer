#! /usr/bin/env ruby

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

before do
  @contents = File.readlines('./data/toc.txt')
end

helpers do
  def in_paragraphs(str)
    str.split("\n\n").map {|para| "<p>#{para}</p>"}.join
  end
end
 
get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  
  erb :home
end

get '/chapters/:number' do
  number = params[:number].to_i
  chapter_name = @contents[number-1]
  
  redirect "/" unless (1..@contents.size).cover? number
  
  chapter_text = File.read("data/chp#{number}.txt")
  @chapter = in_paragraphs(chapter_text)

  @title = "Chapter #{number}: #{chapter_name}"

  erb :chapter
end

not_found do
  redirect "/"
end


# Calls the block for each chapter, passing that chapter's number, name, and
# contents.
def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# This method returns an Array of Hashes representing chapters that match the
# specified query. Each Hash contain values for its :name and :number keys.
def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    results << {number: number, name: name} if contents.include?(query)
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

get "/env" do
  env.map {|k,v| "#{k}:#{v}<br>"}
end
