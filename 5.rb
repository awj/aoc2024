#!/usr/bin/env ruby

module D5
  def self.parse(input)
    # rules are a hash from a candidate page to a list of the pages that must *precede*
    # it.
    rules = {}
    updates = []

    reading_rules = true
    input.lines(chomp: true).each do |l|
      if l == ""
        reading_rules = false
        next
      end

      if reading_rules
        before, candidate = l.split("|").map(&:to_i)
        rules[candidate] ||= []
        rules[candidate] << before
      else
        updates << l.split(",").map(&:to_i)
      end
    end

    [rules, updates]
  end

  def self.p1(input)
    rules, updates = parse(input)

    valid = updates.select do |update|
      in_order?(update, rules)
    end

    valid.map { |u| u[u.size / 2] }.sum
  end

  def self.p2(input)
    rules, updates = parse(input)

    invalid = updates.reject do |update|
      in_order?(update, rules)
    end

    sorted = invalid.map { |update| sort(update, rules) }

    sorted.map { |u| u[u.size / 2] }.sum
  end

  def self.sort(update, rules)
    update.sort do |a, b|
      a_rule = rules[a]
      b_rule = rules[b]

      # If we have rules for both a and b, we *should* only have *one* rule
      # stating the ordering, so nil-out the one that doesn't apply.
      raise "uh oh #{update}" if a_rule && b_rule && a_rule.include?(b) && b_rule.include?(a)

      if a_rule && b_rule
        if a_rule.include?(b)
          b_rule = nil
        elsif b_rule.include?(a)
          a_rule = nil
        end
      end

      if a_rule
        a_rule.include?(b) ? 1 : 0
      elsif b_rule
        b_rule.include?(a) ? -1 : 0
      else
        0
      end
    end
  end

  def self.in_order?(update, rules)
    seen = []

    update.each do |entry|
      if rules[entry]
        return false unless (rules[entry] & seen).uniq.size == (rules[entry] & update).size

        seen << entry
      else
        # No action here since there's no rule defined
        seen << entry
      end
    end

    true
  end
end
