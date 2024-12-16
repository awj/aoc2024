#!/usr/bin/env ruby

module D10
  def self.parse(input)
    map = {}
    by_number = Hash.new do |hsh, k|
      hsh[k] = Array.new
    end

    y = 0
    x = nil
    input.lines(chomp: true).each do |line|
      x = 0

      line.chars.each do |c|
        i = c.to_i
        i = -1 if c == '.'
        loc = [x,y]
        map[loc] = i
        by_number[i] << loc
        x += 1
      end
      y += 1
    end

    extent = [x, y]

    [map, by_number, extent]
  end

  def self.p1(input)
    map, by_number, _extent = parse(input)

    trailheads = by_number[0]

    with_ends = trailheads.map do |start|
      [start, solutions(start, 1, map)]
    end.to_h

    with_ends.values.sum do |v|
      v.uniq.count
    end
  end

  def self.p2(input)
    map, by_number, _extent = parse(input)

    trailheads = by_number[0]

    with_ends = trailheads.map do |start|
      [start, paths([start], 1, map)]
    end.to_h

    with_ends.sum do |k, v|
      puts "#{k}: #{v.uniq.size}"

      v.uniq.size
    end
  end

  def self.paths(path, elevation, map)
    puts path.inspect
    location = path.last
    candidates = around(location, map)

    if elevation == 9
      candidates.select do |c|
        c[1] == 9
      end.map do |c|
        Array[*path, c]
      end
    else
      candidates.flat_map do |c|
        if c[1] == elevation
          np = Array[*path, c.first]
          paths(np, elevation + 1, map)
        end
      end.compact
    end
  end

  def self.solutions(location, elevation, map)
    candidates = around(location, map)

    if elevation == 9
      candidates.select do |c|
        c[1] == 9
      end.map(&:first)
    else
      candidates.flat_map do |c|
        solutions(c[0], elevation + 1, map) if c[1] == elevation
      end.compact
    end
  end

  def self.around(location, map)
    x, y = location

    [
      [[x+1, y], map[[x + 1, y]]],
      [[x-1, y], map[[x - 1, y]]],
      [[x, y + 1], map[[x, y + 1]]],
      [[x, y - 1], map[[x, y - 1]]]

    ]
  end
end
