# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
class RandomStringGenerator

  def initialize
    @charset = %w{ A C D E F G H J K L M N P Q R T V W X Y Z} + [" "]
  end

  def string
    (0...(rand(30)+10)).map{ @charset[rand(@charset.size)] }.join
  end

end


Todo.delete_all
random = RandomStringGenerator.new
(1..50).each do |variable|
  Todo.create(title:random.string)
end


slayer = Artist.find_or_create_by_name("Slayer", name:"Slayer")
metallica = Artist.find_or_create_by_name("Metallica", name:"Metallica")
anthrax = Artist.find_or_create_by_name("Anthrax", name:"Anthrax")
megadeth = Artist.find_or_create_by_name("Megadeth", name:"Megadeth")

Album.find_or_create_by_name("Reign in Blood", name:"Reign in Blood") {|r| r.artist_id = slayer.id }
Album.find_or_create_by_name("Master of Puppets", name:"Master of Puppets" ) {|r| r.artist_id = metallica.id }
Album.find_or_create_by_name("Kill em All", name:"Kill em All") {|r| r.artist_id = metallica.id }
Album.find_or_create_by_name("Among the living", name:"Among the living") {|r| r.artist_id = anthrax.id }
Album.find_or_create_by_name("Spreading the disease", name:"Spreading the disease") {|r| r.artist_id = anthrax.id }
