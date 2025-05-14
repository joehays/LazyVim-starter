--[[
return {
  norg = {
    compile_command = {
      -- Compile the C parser
      "cc", "-o", "parser.so", "-I./src", "src/parser.c", "-Os", "-std=c11", "-shared", "-fPIC",
      "&&",
      -- Compile the C++ scanner separately with the correct flag
      "c++", "-o", "scanner.so", "-I./src", "src/scanner.cc", "-Os", "-std=c++14", "-shared", "-fPIC"
    }
  }
}
]]
