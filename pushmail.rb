require 'rubygems'
require 'tmail'
require 'json'
require 'json/pure'
require 'couchrest'


JSON_ESCAPE_MAP = {
    '\\'    => '\\\\',
    '</'    => '<\/',
    "\r\n"  => '\n',
    "\n"    => '\n',
    "\r"    => '\n',
    '"'     => '\\"' }

def escape_json(json)
  json.gsub(/(\\|<\/|\r\n|[\n\r"])/) { JSON_ESCAPE_MAP[$1] }
end

couch = CouchRest.new("http://127.0.0.1:5984")
@db = couch.database!('unveil')

def pushtocouch(file)
puts "#{file}"
loader = TMail::UNIXMbox.new(file, nil, true)
  loader.each_port do |port|
    mail_hash = Hash.new

    mail = TMail::Mail.new(port)
     
    mail_hash[:to] = mail.to
    mail_hash[:to_addrs] = mail.to_addrs
    mail_hash[:from] = mail.from 
    mail_hash[:from_addrs] = mail.from_addrs
    mail_hash[:subject] = mail.subject
    mail_hash[:body] = escape_json(mail.body)
    mail_hash[:date] = mail.date  

    begin
      @db.save_doc(mail_hash)
    rescue
      puts "Error saving #{mail_hash.to_s}"
    end
   end
end
path = "/Users/michael/Downloads/Fuck FBI Friday/Karim Hijazi & Unveillance/"
files = Dir.glob(path + 'emails/*')
puts "Processing #{files.count} files"
files.each  { |file| pushtocouch(file) }
