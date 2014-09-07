class Dungeon
  attr_accessor :player

  def initialize(player_name)
    @player = Player.new(player_name)
    @rooms = []
    @previous_location = nil
    @knife = false
    @monster = true
    @num_ran = rand(1..10)
    @key = false
  end

  def add_room(reference, name, description, explore, connections)
    @rooms << Room.new(reference, name, description, explore, connections)
  end

  def start(location)
    @player.location = location
    show_current_description
  end

  def show_current_description
    puts find_room_in_dungeon(@player.location).full_description
    if @player.location == :moat
      @player.location = @previous_location
      show_current_description
    else
     interact
    end
  end

  def show_explore_description
    puts find_room_in_dungeon(@player.location).explore_description
    more_room
  end

  def more_room
    case
    when @player.location == :largecave then large_cave_room
    when @player.location == :smallroom then small_cave_room
    when @player.location == :dungeongarden then garden_room
    when @player.location == :closingwalls then closing_walls_room
    when @player.location == :dungeongate then gate_room
    end
  end

  def large_cave_room
    puts "You are close to an exit."
    puts "The apparent object is in a corner of the cave that is very dark."
    puts "Do you still wish to investigate?"
    choice = gets.chomp.downcase

    if choice.include?("y")
      puts "You approach and see a knife. Do you wish to pick it up?"
      choice = gets.chomp.downcase

      if choice.include?("y")
        puts "You grab the knife and put it in your satchel."
        @knife = true
        new_go
      else
        puts "You choose not to pick it up."
        new_go
      end
    else
      puts "You choose not to investigate."
      new_go
    end
  end

  def small_cave_room
    if @monster == true
      puts "All of a sudden, you see a pair of eyes peering back at you."
      puts "A giant monster is running toward toward you."
      puts "It is too dark to see the exit."

      if @knife == true
        puts "You take out your knife and hold it in the monster's direction."
        puts "The blade goes into his giant body and he falls to the ground."
        puts "Good job!"
        @monster = false
        new_go
      else
        puts "The monster jumps on you and starts devouring you."
        puts "It's a really terrible way to go."
        end_game
      end
    else
      puts "The body of monster you killed is the only thing in the room."
      new_go
    end
  end

  def garden_room
    puts "You walk over to the envelope and remove paper inside."
    puts "Do you want to read it?"
    choice = gets.chomp.downcase

    if choice.include?("y")
      puts "On the piece of paper is a number: #{@num_ran}"
      puts "You are unsure what it means."
      puts "You decide to continue exploring."
      new_go
    else
      puts "You choose not to read the note."
      puts "Hopefully nothing useful was written on it."
      new_go
    end
  end

  def gate_room
    if @key == false
      puts "There is no key in sight."
      puts "You decide to continue on and search for the key."
      new_go
    else
      puts "You take out the key and fit it into the lock."
      puts "The key turns and the dungeon gate opens."
      puts "You won!"
      end_game
    end
  end

  def guessing
    puts "You have time to make three guesses of what the number might be."

    puts "Guess. There isn't much time."
    print "> "
    guess_num = gets.chomp.to_i
    guesses = 0

    while guesses <= 1
      if guess_num != @num_ran
        puts "The walls are continuing to close in on you."
        puts "Guess again."
        guesses += 1
      elsif guess_num == @num_ran
        puts "You guessed correctly!"
        puts "The walls stop and you are able to make your way to the back wall."
        puts "You grab the key."
        @key = true
        new_go
      end
      print "> "
      guess_num = gets.chomp.to_i
    end

    puts "Unfortunately you did not guess the correct number."
    puts "The walls close in on you and you are crushed."
    end_game
  end

  def closing_walls_room
    if @key == false
      puts "As soon as you walk over the threshold, the walls start to close in."
      puts "You notice a box on the wall with buttons numbered 1 through 10."
      puts "This might be the way to stop the walls."
      puts "Do you want to leave or try to guess the number?"
      choice = gets.chomp.downcase

      if choice.include?("guess")
        guessing
      elsif choice.include?("leave")
        puts "You leave the room and watch as the walls close in."
        puts "Without the key, you are doomed to a living your final days out in this dungeon."
        end_game
      elsif choice.include?("exit")
        end_game
      else
        puts "I'm sorry. I don't understand."
        closing_walls_room
      end
    else
      puts "The room is empty."
    end
  end

  def find_room_in_dungeon(reference)
    @rooms.detect { |room| room.reference == reference }
  end

  def find_room_in_direction(direction)
    find_room_in_dungeon(@player.location).connections[direction]
  end

  def go(direction)
    puts "You go #{direction.to_s}"
    @previous_location = @player.location
    @player.location = find_room_in_direction(direction)
    if @player.location != :nil
      show_current_description
    else
      puts "There is nothing in there. Try another direction."
      @player.location = @previous_location
      new_go
    end
  end

  def new_go
    dir_array = [:east, :west, :south, :north]

    puts "Where would you like to go: east, west, south, north?"
    new_dir = gets.chomp
    if dir_array.include?(new_dir.to_sym)
      self.go(new_dir.to_sym)
    elsif
      new_dir == "exit"
      end_game
    else
      puts "Please type in a direction."
      new_go
    end
  end

  def interact
    puts "What would you like to do now: explore or go somewhere else?"
    action = gets.chomp

    if action.include?("explore")
      show_explore_description
    elsif action.include?("go")
      new_go
    elsif action.include?("exit")
      end_game
    else
      puts "I don't understand. Please try again."
      interact
    end
  end

  def end_game
    abort("The game is over.")
  end

  class Player
    attr_accessor :name, :location

    def initialize(name)
      @name = name
    end
  end

  class Room
    attr_accessor :reference, :name, :description, :explore, :connections

    def initialize(reference, name, description, explore, connections)
      @reference = reference
      @name = name
      @description = description
      @explore = explore
      @connections = connections
    end

    def full_description
      print @description
    end

    def explore_description
      print @explore
    end
  end
end

puts "What's your name?"
print "> "
name = gets.chomp

$my_dungeon = Dungeon.new(name)

$my_dungeon.add_room(:largecave, "Large Cave",
"You are in a large, dark cave.",
"Far in the distance you see something glistening.",
{:west => :smallroom, :east => :moat, :south => :nil, :north => :dungeongate})

$my_dungeon.add_room(:smallroom, "Small Room",
"You are in a small, dark room.",
"The walls are made of cold concrete.",
{:east => :largecave, :north => :dungeongarden,
:west => :moat, :south => :closingwalls})

$my_dungeon.add_room(:dungeongate, "Dungeon Gate",
"You have reached the dungeon gate.",
"You see a lock with a place for a key.",
{:south => :largecave, :east => :moat, :north => :nil, :west => :nil})

$my_dungeon.add_room(:dungeongarden, "Dungeon Garden",
"You are in a dungeon's garden. It's full of weeds.",
"You notice an envelope on a old, rusty table.",
{:south => :smallroom, :east => :dungeongate, :north => :nil, :west => :nil})

$my_dungeon.add_room(:closingwalls, "Closing Walls Room",
"You approach a doorway and see a key hanging on the far wall.",
"The key is large and silver.",
{:south => :nil, :east => :nil, :north => :smallroom, :west => :nil})

$my_dungeon.add_room(:moat, "Moat",
"You have come to a large moat.It is too deep and rough to swim across.
You have no choice but to turn around.",
"nil",
{:east => :nil, :west => :nil, :north => :nil, :south => :nil})

puts "Hello, #{name}."
puts "You awake to find yourself trapped in a dark dungeon."
puts "You must now find a way out."

$my_dungeon.start(:largecave)
