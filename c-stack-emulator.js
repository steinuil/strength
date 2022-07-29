// In C the data and the return stack are one and the same.
let stack = [];
let stackPointer = 0;
let framePointer = 0;

// This is roughly what happens when you call a function:
function callFunction(functionCode) {
  // Push the frame pointer on top of the stack.
  stack[stackPointer] = framePointer;
  // Set the frame pointer to the stack pointer.
  framePointer = stackPointer;
  // Increase the stack pointer so it points to the new top of the stack.
  stackPointer += 1;

  for (const statement of functionCode) {
    if (statement.type == "variable_declaration") {
      // Push the value of the variable on top of the stack.
      stack[stackPointer] = statement.value;
      // Increase the stack pointer.
      stackPointer += 1;

    } else if (statement.type == "function_call") {
      callFunction(statement.functionCode);

    } else if (statement.type == "return") {
      break;
    }
  }

  // Set the stack pointer to the start of the frame.
  stackPointer = framePointer;
  // Restore the value of the frame and stack pointers to their values from before the function was called.
  framePointer = stack[stackPointer];
  stackPointer -= 1;
}


