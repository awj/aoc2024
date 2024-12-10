#!/usr/bin/env ruby

module D9
  def self.parse(input)
    vals = input.chars.map(&:to_i)
    disk = Array.new(vals.sum)

    free = []

    file_id = 0
    i = 0
    file = false

    vals.each do |x|
      file = !file
      x.times do |n|
        if file
          disk[i + n] = file_id
        else
          free.push(i + n)
        end
      end

      file_id += 1 if file
      i += x
    end

    [disk, free]
  end

  def self.p1(input)
    disk, free = parse(input)

    i = disk.rindex do |b|
      !b.nil?
    end

    loop do
      loc = free.shift

      break if loc > i

      i -= 1 while disk[i].nil?

      disk[loc] = disk[i]
      disk[i] = nil

      # free.push(i)
      # free.sort!
      i -= 1
    end

    disk.each_with_index.sum do |x, i|
      x.nil? ? 0 : x * i
    end
  end

  # Put together a list of all the contiguous files. We'll walk this list
  # backwards to make sure we're moving files from right to left.
  #
  # Then grab a list of contiguous chunks of file space. We'll look through this
  # list from left to right to find space for a file. Note that we can "use"
  # part of a free block of space, in which case we need to update it to denote
  # the remaining free space. If we use all of it, just delete it.
  def self.p2(input)
    disk, free = parse(input)

    files = calc_files(disk)

    free_blocks = free.chunk_while { |x, y| x+1 == y }.to_a

    while file = files.pop
      id, start, size = file

      # Funky indexing here to make sure that the first block we see has index
      # 0. We're looking for a block that starts *before* the file we're tryiing
      # to move, and has at least that much free space.
      i = -1
      block = free_blocks.find do |b|
        i += 1
        b.first < start && b.size >= size
      end

      # If we didn't find a suitable free block, go to the next file.
      next if block.nil?

      bstart = block.first
      bsize = block.size

      # If we're consuming part of a free block, update it to reflect remaining
      # space.
      if bsize > size
        nbstart = bstart + size
        nb = (bsize - size).times.map do |i|
          nbstart + i
        end

        free_blocks[i] = nb
      else
        free_blocks.delete_at(i)
      end

      # Mark the disk sectors for the free block and nil-out the ones we're
      # moving.
      size.times do |i|
        disk[bstart + i] = id
        disk[start + i] = nil
      end
    end

    [disk, free, files]
  end

  def self.calc_files(disk)
    files = []

    file_id = nil

    file = nil
    disk.each_with_index do |x, i|
      if x.nil?
        files.push(file) if file
        file = nil
        next
      end

      if !file_id.nil? && x != file_id
        files.push(file) if file
        file = nil
      end

      if file.nil?
        file = [x, i, 1]
        file_id = x
      else
        file[2] = file[2] + 1
      end
    end

    files.push(file) if file
  end
end
