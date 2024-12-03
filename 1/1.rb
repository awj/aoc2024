
module D1
  def self.parse(input)
    input.lines.map do |l|
      l.split(" ").map(&:to_i)
    end.transpose
  end

  def self.p1(l1, l2)
    l1.sort.zip(l2.sort).map do |v1, v2|
      (v1 - v2).abs
    end.sum
  end

  def self.p2(l1, l2)
    l2_occur = l2.tally

    l1.sum do |v|
      mul = l2_occur[v] || 0
      v * mul
    end
  end
end
