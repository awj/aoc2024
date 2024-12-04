#!/usr/bin/env ruby

module D4
  def self.parse(input, seek)
    y = 0

    map = {}
    locs = []

    input.lines.each do |line|
      x = 0
      line.chomp.chars.each do |c|
        loc = [x, y]
        map[loc] = c
        locs << loc if c == seek
        x += 1
      end
      y += 1
    end

    [map, locs]
  end

  def self.p2(input)
    map, ms = parse(input, 'M')

    # A map each from 'A' in a 'MAS' to an array of the 'M' locations that
    # started it.
    as = {}

    ms.each do |loc|
      cross(loc).select do |vs|
        name = vs.map do |v|
          map[v]
        end.join

        name == "MAS"
      end.each do |path|
        as[path[1]] ||= []
        as[path[1]] << path.first
      end
    end

    as.values.count do |v|
      v.size > 1
    end
  end

  def self.cross(loc)
    [
      vector(loc, 2, [1, -1]),
      vector(loc, 2, [1, 1]),
      vector(loc, 2, [-1, -1]),
      vector(loc, 2, [-1, 1]),
    ]
  end

  def self.p1(input)
    map, xs = parse(input, 'X')

    xs.sum do |loc|
      dirs(loc).count do |vs|
        name = vs.map do |v|
          map[v]
        end.join

        name == "XMAS"
      end
    end
  end

  def self.vector(loc, distance, dir)
    v = [loc]

    distance.times do
      loc = [loc[0] + dir[0], loc[1] + dir[1]]
      v << loc
    end

    v
  end

  def self.dirs(loc)
    [
      vector(loc, 3, [1, 0]),
      vector(loc, 3, [-1, 0]),
      vector(loc, 3, [0, 1]),
      vector(loc, 3, [0, -1]),
      vector(loc, 3, [1, -1]),
      vector(loc, 3, [1, 1]),
      vector(loc, 3, [-1, -1]),
      vector(loc, 3, [-1, 1]),
    ]
  end
end
