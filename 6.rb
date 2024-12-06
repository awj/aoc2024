#!/usr/bin/env ruby

module D6
  class Guard
    attr_reader :location, :direction

    def initialize(location, direction = :up)
      @location = location
      @direction = direction
    end

    def move(map)
      candidate = advance

      if map[candidate]
        @direction = rotate
      else
        @location = candidate
      end

      location
    end

    def rotate
      case direction
      when :up then :right
      when :right then :down
      when :down then :left
      when :left then :up
      end
    end

    def advance
      case direction
      when :up then [location[0], location[1] - 1]
      when :down then [location[0], location[1] + 1]
      when :right then [location[0] + 1, location[1]]
      when :left then [location[0] - 1, location[1]]
      end
    end
  end

  def self.parse(input)
    map = {}
    guard = nil
    y = 0
    x = nil
    input.lines(chomp: true).each do |l|
      x = 0
      l.chars.each do |c|
        if c == "#"
          map[[x,y]] = "#"
        elsif c == "^"
          guard = [x, y]
        end

        x += 1
      end
      y += 1
    end

    [map, guard, [x, y]]
  end

  def self.p1(input)
    map, guard, extent = parse(input)

    guard = Guard.new(guard)

    seen = Set.new([guard.location])

    loop do
      guard.move(map)

      puts guard.location.inspect

      break unless in_bounds?(guard.location, extent)

      seen << guard.location
    end

    seen.size
  end

  # This is an *incredibly* inefficient way to get the answer, but:
  # * generate a list of "candidate" maps with a new block in each empty location
  # * simulate those maps
  # * if we simulate more than 50k steps (arbitrary number), guard is in a loop
  #
  # Likely we could do better by:
  # * keeping a list of the points where the guard *turned*, location and direction
  # * looking for a point where the guard reaches a previously seen location and
  #   direction
  #
  # It feels like we should be able to "calculate" the number of looping maps by
  # storing a list of all the locations/directions where we've turned, then
  # before advancing forward say "if we had a block here instead, would that
  # result in us hitting a previously seen location/direction". That *only*
  # works for cases where we're doing "first order" loops. If a new block would
  # create a loop where the very first obstruction is one we haven't hit before,
  # this won't work. It works for all six of the examples in the test, but I
  # suspect doesn't work in general.
  def self.p2(input)
    map, guard, extent = parse(input)

    mx, my = extent

    candidates = []

    my.times do |y|
      mx.times do |x|
        next if guard == [x,y] || map[[x,y]]

        candidates << map.merge([x,y] => "#")
      end
    end

    puts "evaluating #{candidates.size}"

    candidates.count do |cmap|
      loop?(cmap, guard, extent)
    end
  end

  def self.loop?(map, guard, extent)
    guard = Guard.new(guard)

    steps = 0

    loop do
      guard.move(map)

      return false unless in_bounds?(guard.location, extent)

      steps += 1

      return true if steps > 50_000
    end
  end

  def self.in_bounds?(location, extent)
    x, y = location

    mx, my = extent

    return x >= 0 && y >= 0 && x < mx && y < my
  end
end
