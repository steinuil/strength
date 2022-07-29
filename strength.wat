;; Stuff to keep track of:
;;
;; - Dictionary
;;
;;   The memory of the program.
;;   Contains all word headers and definitions, but also just about whatever you wanna put in there.
;;
;; - Data stack and stack pointer
;;
;;   The data stack is "the stack" in Forth. It's where you push and pop all your numbers.
;;   The stack pointer points to the top of the stack:
;;   pushing something onto the stack will increase the stack pointer
;;   and popping will decrease it.
;;
;; - Instruction pointer
;;
;;   The pointer to the address of the function that's currently executing.
;;
;; - Return stack and frame pointer
;;
;;   The return stack is like a function frame in C.
;;   Calling a word will push the value of the instruction pointer +1 to the top of the stack
;;   and increase the stack pointer.
;;   After the word has finished execution it will pop the return stack into the instruction pointer
;;   and decrease the stack pointer.
;;
(module

  (import "host" "print" (func $print_i32 (param i32)))
  (import "host" "print" (func $print_i64 (param i64)))

  ;; The memory layout for this implementation is:
  ;;
  ;;  64k | Data stack
  ;;  64k | Return stack
  ;;  32b | Word name buffer
  ;; rest | Dictionary
  (memory 4)

  (table 2 funcref)
  (elem (i32.const 0)
        $drop
        $swap
        )


  (type $fn (func (param i32) (param i32) (param i32) (result i32 i32 i32)))

  (func (export "main")
        call $init_registers

        i64.const 2
        call $push_stack
        i64.const 3
        call $push_stack
        call $add
        call $print_stack
        call $print_registers

        ;; Do stuff

        drop
        drop
        drop)

  (func $init_registers (result i32 i32 i32)
        ;; Stack pointer
        i32.const 0

        ;; Frame pointer
        i32.const 0x1_0000

        ;; Instruction pointer
        i32.const 5)

  ;; Structure of a dictionary entry:
  ;; 2b  - Link to previous word
  ;; 1b  - Length of the word name + flags
  ;; len - Word name
  ;; ?   - Codeword
  (func $insert_word
        (param $here i32)
        (param $link i32) ;; pointer to use in i32.store16 (0 if it's the first word)
        (param $immediate i32) ;; 1 or 0
        (param $hidden i32) ;; 1 or 0
        (result i32) ;; pointer to the start of the codeword

        ;; Word length
        (local $wl i32)

        ;; Store the link to the last word
        (i32.store16 (local.get $link) (local.get $here))

        ;; Copy the name of the word from the word buffer at 0x20000 to the word header
        ;; and save the length of the name in $wl
        (local.set $wl (i32.const 0))
        (loop $copy_word
          (i32.eqz (i32.load8_u (i32.add (local.get $wl)
                                         (i32.const 0x2_0000))))
          (if
            (then
              (br $copy_word))
            (else
              (i32.store8
                ;; The byte at position word buffer + word length
                (i32.load8_u (i32.add (local.get $wl)
                                      (i32.const 0x2_0000)))
                ;; The position at the start of the header + link + len + word length
                (i32.add (i32.add (local.get $here)
                                  (i32.const 3)) ;; link (2) + len (1)
                         (local.get $wl)))

              (local.set $wl (i32.add (local.get $wl)
                                      (i32.const 1))))))

        ;; Store the word len and its flags
        (i32.store8
          ;; $immediate << 7 | $hidden << 5 | $wp
          (i32.or (i32.or (i32.rotl (local.get $immediate) (i32.const 7))
                          (i32.rotl (local.get $hidden) (i32.const 5)))
                  (local.get $wl))
          ;; $here + link (2)
          (i32.add (local.get $here)
                   (i32.const 2)))


        ;; Return pointer to the codeword
        (i32.add (i32.add (local.get $here)
                          (local.get 3))
                 (local.get $wl)))

  (func $init_words
        (i64.const 7017280452245743464)
        drop)



  (func $print_registers
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)
        local.get $sp
        call $print_i32
        local.get $fp
        call $print_i32
        local.get $ip
        call $print_i32
        i32.const -1
        call $print_i32

        local.get $sp
        local.get $fp
        local.get $ip)


  ;; Utilities for increasing and decreasing data/frame pointers by 1
  (func $incrp (param $pointer i32) (result i32)
        (i32.add (local.get $pointer) (i32.const 8)))
  (func $decrp (param $pointer i32) (result i32)
        (i32.sub (local.get $pointer) (i32.const 8)))

  (func $print_stack
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        (call $print_i64 (i64.load (local.get $sp)))

        local.get $sp
        local.get $fp
        local.get $ip)

  (func $push_stack
        (param $sp i32) (param $fp i32) (param $ip i32)
        (param $val i64)
        (result i32 i32 i32)

        (i64.store (local.get $sp) (local.get $val))
        
        (call $incrp (local.get $sp))
        local.get $fp
        local.get $ip)


  (func $drop
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        (call $decrp (local.get $sp))
        local.get $fp
        local.get $ip)

  (func $add
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        (local.set $sp (call $decrp (local.get $sp)))

        local.get $sp

        (i64.load (local.get $sp))
        (i64.load (call $decrp (local.get $sp)))
        i64.add

        i64.store

        local.get $sp
        local.get $fp
        local.get $ip)



  (func $swap (param $x i64) (param $y i64) (result i64 i64)
        local.get $y
        local.get $x)

)
