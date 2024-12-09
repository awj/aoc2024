#!/usr/bin/env ruby

module D7
  def self.parse(input)
    input.lines(chomp: true).map do |line|
      test, equation = line.split(":")
      values = equation.split(" ").map(&:to_i)
      [test.to_i, values]
    end
  end

  # Come up with all possible permutations of operators between the values. Example:
  # using [1, 2, 3]
  # 1 + 2 + 3
  # 1 + 2 * 3
  # 1 * 2 + 3
  # 1 * 2 * 3
  def self.p1(input)
    parse(input).select do |line|
      test, values = line

      permutations(values, [:+, :*]).any? do |total|
        test == total
      end
    end.sum(&:first)
  end

  # Same algorithm as above, but use `:comb` in place of `||` to indicate
  # "combining" values. This winds up being *really* slow, because we end up
  # evaluating the same "dead end" permutations that share a common "prefix"
  # which pushes them over the total.
  def self.p2(input)
    parse(input).select do |line|
      test, values = line

      permutations(test, values, [:+, :*, :comb]).any? do |total|
        test == total
      end
    end.sum(&:first)
  end

  # Optimize p2 by only evaluating a potential list of operators up to the point
  # where it exceeds the test value. Example:
  # 75: 5 5 5 5
  #
  # First step with each operator
  # 5 + 5 = 10 (ok, we're below the test)
  # 5 * 5 = 25 (ok, we're below the test)
  # 5 || 5 = 55 (ok, we're below the test)
  #
  # Second step with each operator
  # (5 + 5) + 5 = 15 (ok, below test)
  # (5 + 5) * 5 = 50 (ok, below test)
  # (5 + 5) || 5 = 105 (fail, we're above the test)
  #
  # Note that any potential operations starting with 5 + 5 || 5 *will* fail. We
  # don't even have to check everything that could result from it. Which in this
  # case saves us checking 3 entire operators. For longer lists of values this
  # is a huge savings since we're talking about n^3 potential paths where n ==
  # the number of remaining elements.
  #
  # On my machine this is roughly 12x faster than the original (2.14s vs 25.92s)
  def self.fast_p2(input)
    parse(input).select do |line|
      test, values = line

      solves?(test, values, values.first, 1)
    end.sum(&:first)
  end

  # Breadth-first recursive evaluation of test: values for potential solutions.
  # Short circuit if at any point we exceed the test value, which avoids us
  # having to check all of the permutations of operators against the remainder
  # of the list of values.
  def self.solves?(test, values, memo, idx)
    return test == memo if values[idx].nil?

    return false if memo > test

    [:+, :*, :comb].any? do |op|
      val = values[idx]

      nmemo = if op == :comb
               # Weird trick here: 10 ** val.digits.size gives us a power of ten
               # equal to the number of decimal places.
               # val = 1 => 10 ** 1 == 10
               # val = 12 => 10 ** 2 == 100
               # val = 123 => 10 ** 3 == 1000
               #
               # Multiplying our running total by this value "pushes it" that
               # many decimal places out, making room to add val for the
               # combination.
               # memo = 12, val = 345
               # 12 * (10 ** 3) + 345
               # 12 * (1000) + 345
               # 12000 + 345
               # 12345
               #
               # This is slightly faster than using an intermediate string that
               # we re-parse into an integer.
               memo * (10**val.digits.size) + val
             else
               memo.send(op, val)
             end

      solves?(test, values, nmemo, idx + 1)
    end
  end

  def self.permutations(test, values, operators)
    operators.repeated_permutation(values.size - 1).lazy.map do |stack|
      run(test, values, stack)
    end
  end

  def self.run(test, values, stack)
    values.reduce do |memo, val|
      if memo > test
        return memo
      end

      op = stack.pop

      if op == :comb
        "#{memo}#{val}".to_i
      else
        memo.send(op, val)
      end
    end
  end
end
