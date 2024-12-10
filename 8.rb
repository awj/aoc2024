#!/usr/bin/env ruby

module D8
  def self.parse(input)
    antennas = {}
    map = {}

    y = 0
    x = 0

    input.lines(chomp: true).each do |line|
      x = 0
      line.chars.each do |c|
        if c != '.'
          loc = [x, y]
          antennas[c] ||= []
          antennas[c] << loc
          map[loc] = c
        end

        x += 1
      end
      y += 1
    end

    [antennas, map, [x, y]]
  end

  def self.p1(input)
    antennas, map, extent = parse(input)

    # Use a set so we don't count the same location twice across antenna types.
    antipodes = Set.new

    antennas.values.each do |locations|
      puts locations.combination(2).to_a.inspect
      locations.combination(2).each do |pair|
        p1, p2 = pair

        v1 = vector(p1, p2)
        v2 = vector(p2, p1)

        puts "checking: #{v1} #{v2}"
        puts "against: #{p1} #{p2}"

        c1 = add(p2, v1)
        c2 = add(p1, v2)

        puts "antipodes: #{c1} #{c2}"

        antipodes << c1 if on_map?(c1, extent)
        antipodes << c2 if on_map?(c2, extent)
      end
    end

    antipodes.size
  end

  def self.p2(input)
    antennas, map, extent = parse(input)

    # Use a set so we don't count the same location twice across antenna types.
    antipodes = Set.new

    antennas.values.each do |locations|
      puts locations.combination(2).to_a.inspect
      locations.combination(2).each do |pair|
        p1, p2 = pair

        v1 = vector(p1, p2)
        v2 = vector(p2, p1)

        puts "checking: #{v1} #{v2}"
        puts "against: #{p1} #{p2}"

        c1 = add(p1, v1)
        while on_map?(c1, extent)
          antipodes << c1
          c1 = add(c1, v1)
        end

        c2 = add(p2, v2)
        while on_map?(c2, extent)
          antipodes << c2
          c2 = add(c2, v2)
        end
      end
    end

    antipodes.size
  end

  def self.on_map?(p, extent)
    puts "checking if #{p} is on #{extent}"
    x, y = p
    mx, my = extent

    return false if x < 0 || y < 0

    x < mx && y < my
  end

  def self.add(p, v)
    x, y = p
    dx, dy = v

    [x + dx, y + dy]
  end

  def self.vector(p1, p2)
    x1, y1 = p1
    x2, y2 = p2

    [x2 - x1, y2 - y1]
  end

  def self.invert(vector)
    x, y = vector

    [-x, -y]
  end
end
