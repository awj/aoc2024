#!/usr/bin/env ruby

module D2
  def self.parse(input)
    input.lines.map do |l|
      l.split(" ").map(&:to_i)
    end
  end

  def self.p1(input)
    input.count do |report|
      p1, p2 = report.take(2)

      if p1 == p2
        false
      else
        dir = p1 < p2 ? :asc : :desc

        report.each_cons(2).all? do |cons|
          p1, p2 = cons
          safe?(p1, p2, dir)
        end
      end
    end
  end

  def self.p2(input)
    input.count do |report|
      safe_dampened?(report)
    end
  end

  # BRUTE FORCE!!!! List out all permutations of "the array except for one
  # element". Check to see if the original array or any permutation are
  # "classically" safe.
  def self.safe_dampened?(report)
    permutations = [report]

    report.size.times do |i|
      r2 = report.dup
      r2.delete_at(i)
      permutations << r2
    end

    permutations.any? do |rp|
      p1, p2 = rp.take(2)

      if p1 == p2
        false
      else
        dir = p1 < p2 ? :asc : :desc

        rp.each_cons(2).all? do |cons|
          p1, p2 = cons
          safe?(p1, p2, dir)
        end
      end
    end
  end

  def self.safe?(p1, p2, dir)
    diff = p2 - p1

    return false if (diff <=> 0).zero?

    org = dir == :asc ? (p1 < p2) : (p1 > p2)

    org && (1..3).include?((p1 - p2).abs)
  end
end
