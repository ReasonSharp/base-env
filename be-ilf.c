#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

#define ERROR 1000
#define MAX_TOKEN_SIZE 4096
#define INCREMENT_SIZE 100

typedef struct uintStack {
 unsigned int increment_size;
 unsigned int current_size;
 unsigned int *stack;
} UIntStack;

UIntStack *uintstack_create(unsigned int initial_size) {
 if (initial_size == 0) return NULL;
 UIntStack *stack = (UIntStack *)malloc(sizeof(UIntStack));
 stack->increment_size = initial_size;
 stack->current_size = 0;
 stack->stack = (unsigned int *)malloc(sizeof(unsigned int) * initial_size);
 return stack;
}
void uintstack_delete(UIntStack *stack) {
 if (stack != NULL) {
  if (stack->stack != NULL) free(stack->stack);
  free(stack);
 }
}
void uinstack_push(UIntStack *stack, unsigned int number) {
 if (stack == NULL || stack->stack == NULL) return;
 if (stack->current_size % stack->increment_size == 0) {
  unsigned int new_size = stack->increment_size * (stack->current_size / stack->increment_size + 1);
  stack->stack = (unsigned int *)realloc(stack->stack, sizeof(unsigned int) * new_size);
 }
 stack->stack[stack->current_size] = number;
 ++stack->current_size;
}
unsigned int uintstack_pop(UIntStack *stack) {
 if (stack == NULL || stack->stack == NULL || stack->current_size == 0) return ERROR;
 --stack->current_size;
 return stack->stack[stack->current_size];
}
unsigned int uintstack_peek(UIntStack *stack) {
 if (stack == NULL || stack->stack == NULL || stack->current_size == 0) return ERROR;
 return stack->stack[stack->current_size - 1];
}
void uintstack_print(UIntStack *stack) {
 if (stack == NULL) printf("stack => NULL\n");
 else {
  printf("stack size = %d\n", stack->current_size);
  if (stack->stack != NULL && stack->current_size > 0)
   for (unsigned int x = stack->current_size - 1; x < UINT_MAX; --x)
    printf("POS %d: %d\n", x, stack->stack[x]);
 }
}

unsigned int set_state(UIntStack *stack, unsigned int state) {
 uinstack_push(stack, state);
 return state;
}

#define INITIAL      0
#define DOUBLE_QUOTE 1
#define SINGLE_QUOTE 2
#define BACKTICK     3
#define BACKSLASH    4
#define IF_BLOCK     5
#define FOR_LOOP     6
#define WHILE_LOOP   7
#define O_BRACKET    8
#define C_BRACKET    9
#define S_BRACKET    10
#define PIPE         11
#define OR_OP        12
#define AMP          13
#define AND_OP       14
#define HEREDOC      15
#define CASE_BLOCK   16
#define IN_TOKEN     17
#define IN_COMMAND   18

#define DOUBLE_QUOTE_POSSIBLE_VAR 100
#define POSSIBLE_VAR              101

int parse(const char *line) {
 size_t len = strlen(line);
 char c = '\0';
 UIntStack *stack = uintstack_create(INCREMENT_SIZE);
 unsigned int state = set_state(stack, INITIAL);
 char token[MAX_TOKEN_SIZE + 1];
 int ctoks = 0;
 int tracktok = 0;
 for (int x = 0; x < len; ++x) {
  c = line[x];
  printf("%d => '%c'", state, c);
  switch (state) {
  case INITIAL:
   tracktok = 1;
        if (c == '"') state = set_state(stack, DOUBLE_QUOTE);
   else if (c == '\'') state = set_state(stack, SINGLE_QUOTE);
   else if (c == '`') state = set_state(stack, BACKTICK);
   else if (c == '\\') state = set_state(stack, BACKSLASH);
   else if (c == '(') state = set_state(stack, O_BRACKET);
   else if (c == '{') state = set_state(stack, C_BRACKET);
   else if (c == '[') state = set_state(stack, S_BRACKET);
   else if (c == '|') state = set_state(stack, PIPE);
   else if (c == '&') state = set_state(stack, AMP);
   else if (c == ' ') break;
   else {
    state = IN_TOKEN;
    token[ctoks++] = c;
   }
   break;
  case DOUBLE_QUOTE:
   tracktok = 0;
   if (c == '"') {
    uintstack_pop(stack);
    state = uintstack_peek(stack);
   } else if (c == '\\') state = BACKSLASH;
   else if (c == '`') state = set_state(stack, BACKTICK);
   else if (c == '$') state = DOUBLE_QUOTE_POSSIBLE_VAR;
   break;
  case DOUBLE_QUOTE_POSSIBLE_VAR:
        if (c == '{') state = set_state(stack, C_BRACKET);
   else if (c == '(') state = set_state(stack, O_BRACKET);
   else if (c == '[') state = set_state(stack, S_BRACKET);
   else state = DOUBLE_QUOTE;             // yes, because e.g. echo "$'\u123" will just print $'\u123 and won't look for matching quote, and a similar eval will result in syntax error
   break;
  case BACKSLASH:
   if (tracktok == 1) token[ctoks++] = c; // because none of the states where behavior is different track tokens
   state = uintstack_peek(stack);         // we can do this because we don't care about multi-character escape sequences
   break;
  case IN_TOKEN: // TODO
   if (c == ' ') state = uintstack_peek(stack);
   break;
  }
  printf(" => %d\n", state);
 }
 uintstack_print(stack);
 if (stack->current_size == 1 && stack->stack[0] == INITIAL) return 0;
 else return 1;
}

/**
 * base-env is line finished (be-ilf)
 * parses the CLI input of a BASH shell to determine whether the shell would expect another line of input and print $PS2
 * outputs a value to stdout indicating the result:
 *  0 - the line is finished
 *  1 - BASH should output $PS2
 *  2 - invalid heredoc delimiter word (like most shells, we don't support newlines in heredoc delimiters,
 *      but unlike most shells we're going to tell the user about it)
 * 
 * returns:
 *  0 - everything went fine
 *  1 - missing or too many arguments (CLI line)
 **/
int main(int argc, const char *argv[]) {
 printf("argc = %d\n", argc);
 for (int x = 0; x < argc; ++x) {
  printf("argv[%d] = '%s'\n", x, argv[x]);
 }
 if (argc != 2) return 1;
 const char *line = argv[1];
 printf("%d\n", parse(line));
 return 0;
}