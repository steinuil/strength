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
        i32.const 65536

        ;; Instruction pointer
        i32.const 5)

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


  (func $print_stack
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        local.get $sp
        i64.load
        call $print_i64

        local.get $sp
        local.get $fp
        local.get $ip)

  (func $push_stack
        (param $sp i32) (param $fp i32) (param $ip i32)
        (param $val i64)
        (result i32 i32 i32)

        (i64.store (local.get $sp) (local.get $val))
        
        (i32.add (local.get $sp) (i32.const 8))
        local.get $fp
        local.get $ip)


  (func $drop
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        (i32.sub (local.get $sp) (i32.const 8))

        local.get $fp
        local.get $ip)

  (func $add
        (param $sp i32) (param $fp i32) (param $ip i32) (result i32 i32 i32)

        (i32.sub (local.get $sp) (i32.const 8))
        local.set $sp

        ;; Set up destination for storing result later
        local.get $sp

        local.get $sp
        i64.load

        (i32.sub (local.get $sp) (i32.const 8))
        i64.load

        i64.add

        i64.store

        local.get $sp
        local.get $fp
        local.get $ip)



  (func $swap (param $x i64) (param $y i64) (result i64 i64)
        local.get $y
        local.get $x)

)
