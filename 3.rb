#!/usr/bin/env ruby

module D3
  MUL_REGEX = /mul\(([0-9]+),([0-9]+)\)/m
  P2_REGEX = /(do\(\))|mul\(([0-9]+),([0-9]+)\)|(don't\(\))/m

  def self.parse(input)
    input.scan(MUL_REGEX).map do |pair|
      pair.map(&:to_i)
    end
  end

  def self.parse_p2(input)
    input.scan(P2_REGEX).map do |match|
      match.compact!
      if match.size == 2
        match.map(&:to_i)
      else
        match
      end
    end
  end

  def self.p1(input)
    parse(input).sum do |pair|
      pair[0] * pair[1]
    end
  end

  def self.p2(input)
    sum = 0
    running = true

    parse_p2(input).each do |match|
      if match == ["do()"]
        running = true
      elsif match == ["don't()"]
        running = false
      elsif running
        sum += match[0].to_i * match[1].to_i
      end
    end

    sum
  end
end
