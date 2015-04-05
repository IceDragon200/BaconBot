require 'bacon_bot/http'

describe Bacon::HTTPRequestHelper do
  context 'plain' do
    it 'should request a plaintext page' do
      r = subject.plain('https://google.com')
      expect(r.data).to be_kind_of(String)
    end
  end

  context 'html' do
    it 'should request a HTML page' do
      r = subject.html('https://google.com')
      expect(r.data).to be_kind_of(Nokogiri::HTML::Document)
    end
  end

  context 'xml' do
    it 'should request a XML page' do
      r = subject.xml('https://google.com')
      expect(r.data).to be_kind_of(Nokogiri::XML::Document)
    end
  end

  context 'json' do
    it 'should request a JSON page' do
      r = subject.json('http://jsonplaceholder.typicode.com/posts')
      expect(r.data).to be_kind_of(Array)
    end
  end
end
