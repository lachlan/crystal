#!/usr/bin/env bin/crystal --run
require "spec"
require "net/http"

describe "HTTP" do
  describe "Request" do
    it "serialize GET" do
      request = HTTPRequest.new :get, "/", {"Host" => "host.domain.com"}
      io = String::Buffer.new
      request.to_io(io)
      io.to_s.should eq("GET / HTTP/1.1\r\nHost: host.domain.com\r\n\r\n")
    end

    it "serialize POST (with body)" do
      request = HTTPRequest.new :post, "/", nil, "thisisthebody"
      io = String::Buffer.new
      request.to_io(io)
      io.to_s.should eq("POST / HTTP/1.1\r\nContent-Length: 13\r\n\r\nthisisthebody")
    end

    it "parses GET" do
      request = HTTPRequest.from_io(StringIO.new("GET / HTTP/1.1\r\nHost: host.domain.com\r\n\r\n"))
      request.method.should eq("GET")
      request.path.should eq("/")
      request.headers.should eq({"host" => "host.domain.com"})
    end

    it "parses POST (with body)" do
      request = HTTPRequest.from_io(StringIO.new("POST /foo HTTP/1.1\r\nContent-Length: 13\r\n\r\nthisisthebody"))
      request.method.should eq("POST")
      request.path.should eq("/foo")
      request.headers.should eq({"content-length" => "13"})
      request.body.should eq("thisisthebody")
    end
  end

  describe "Response" do
    it "parses response with body" do
      response = HTTPResponse.from_io(StringIO.new("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 5\r\n\r\nhelloworld"))
      response.version.should eq("HTTP/1.1")
      response.status_code.should eq(200)
      response.status_message.should eq("OK")
      response.headers["content-type"].should eq("text/plain")
      response.headers["content-length"].should eq("5")
      response.body.should eq("hello")
    end

    it "parses response without body" do
      response = HTTPResponse.from_io(StringIO.new("HTTP/1.1 404 Not Found\r\n\r\n"))
      response.status_code.should eq(404)
      response.status_message.should eq("Not Found")
      response.headers.length.should eq(0)
      response.body.should be_nil
    end

    it "parses response with chunked body" do
      response = HTTPResponse.from_io(io = StringIO.new("HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n5\r\nabcde\r\na\r\n0123456789\r\n0\r\n"))
      response.body.should eq("abcde0123456789")
      io.gets.should be_nil
    end

    it "serialize with body" do
      response = HTTPResponse.new("HTTP/1.1", 200, "OK", {"Content-Type" => "text/plain", "Content-Length" => "5"}, "hello")
      io = String::Buffer.new
      response.to_io(io)
      io.to_s.should eq("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 5\r\n\r\nhello")
    end
  end
end
