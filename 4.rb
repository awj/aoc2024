#!/usr/bin/env ruby

module D4
  def self.parse(input)
    y = 0

    map = {}
    xs = []

    input.lines.each do |line|
      x = 0
      line.chomp.chars.each do |c|
        loc = [x, y]
        map[loc] = c
        xs << loc if c == 'X'
        x += 1
      end
      y += 1
    end

    [map, xs]
  end

  def self.p1(input)
    map, xs = parse(input)

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
