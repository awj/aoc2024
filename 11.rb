#!/usr/bin/env ruby

module D11
  def self.parse(input)
    input.split.map(&:to_i)
  end

  # For p1, we just *directly* simulate the behavior of the stones. For each
  # blink, create a new list of stones representing the result, then on the next
  # blink we use that list.
  def self.p1(input, blinks = 25)
    stones = parse(input)

    blinks.times do |i|
      stones = blink(stones)
    end

    stones.size
  end

  # Upping the run count to 75 showed just how *expensive* that answer was. Tons
  # and tons of re-creating arrays.
  #
  # Worth noting here is that the *order* of stones doesn't actually matter. The
  # stones never "combine" or rely on each other in any way. They only grow or
  # split.
  #
  # So instead of "simulate each step", we can switch to "count the number of
  # stones produced by a given number of steps for each stone". We still have to
  # simulate the steps for that one stone, but it avoids having to build up
  # *tons* of arrays.
  #
  # Except, even with that, there's consistency. Performing the same number of
  # "blinks" on a given number will always give us the same result. So we can
  # further enhance things by caching the number of stones we ended up with for
  # each pair of stones + number of blinks.
  #
  # Doing so for each "level" of the computation allows us to skip a significant
  # number of simulation steps (~1.1m in my calculations)
  def self.p2(input)
    stones = parse(input)

    stones.sum do |s|
      run(s, 75)
    end
  end

  def self.memo
    @memo ||= Hash.new
  end

  def self.hit
    @hits ||= 0
    @hits += 1
  end

  def self.hits
    @hits
  end

  def self.misses
    @misses
  end

  def self.ratio
    total = hits + misses

    100.0 * hits / total
  end

  def self.miss
    @misses ||= 0
    @misses += 1
  end

  def self.skipped(x)
    @skipped ||= 0
    @skipped += x
  end

  def self.nskipped
    @skipped
  end

  def self.run(stone, blinks)
    return 1 if blinks == 0

    key = [stone, blinks]

    if memo[key]
      hit
      skipped(blinks)
      return memo[key]
    end

    miss

    steps = simulate(stone)

    memo[key] = steps.sum do |ns|
      run(ns, blinks - 1)
    end
  end

  def self.blink(stones)
    stones.flat_map do |s|
      result = simulate(s)

      result
    end
  end

  def self.simulate(s)
    return [1] if s == 0

    sstr = s.to_s
    if sstr.size.even?
      left, right = [sstr[0...(sstr.size / 2)], sstr[(sstr.size / 2)..sstr.size]]

      return [left, right].map(&:to_i)
    end

    [s * 2024]
  end
end
