WORDS = [
  "DROP",
  "SWAP",
  "DUP",
  "OVER",
  "ROT",
  "-ROT",
  "SYSCALL3"
]

puts "(local $last_word i32)"
puts "(local $here i32)"
puts "(local.set $last_word (i32.const 0))"
puts "(local.set $here (i32.const 0x2_0020))"

WORDS.each.with_index do |word, wc|
  puts
  puts ";; store #{word}"

  (word + "\0").bytes.each_slice(8).map do |bytes|
    block = bytes.each.with_index.reduce(0) do |sum, (b, i)|
      sum | b << i * 8
    end
  end.each.with_index do |block, i|
    puts "(i64.store (i64.const 0x#{block.to_s 16}) (i32.const 0x#{(0x2_0000 + i * 8).to_s 16}))"
  end

  puts
  puts "(call $insert_word"
  puts "  (local.get $here)"
  puts "  (local.get $last_word)"
  puts "  (i32.const 0)"
  puts "  (i32.const 0))"
  puts
  puts "(local.set $last_word (local.get $here))"
  puts "local.set $here"
  puts
  puts "(i32.store16 (i32.const #{wc}) (local.get $here))"
  puts ";; NEXT?"
  puts "(local.set $here (i32.add (local.get $here) (i32.const 2)))"
end
