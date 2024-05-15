# HerbAutomaticAbstraction
## Shortening Synthesized Programs using Common Subprograms in Solutions to Simpler Problems

This project depends on
[Herb.jl](https://herb-ai.github.io/) and will possibly be integrated into that project in the future. This repository is to be used for testing while I do my research project.

The following information, and the workings of the project, have been based on the work on DreamCoder by Ellis, et. al. Huge credits to them.

Program synthesis is the process of automatically producing a program which can satisfy a high level specification. It is a hard problem which can take a long time using brute force algorithms.

One of the ways to optimize this is to limit the search space, so the synthesizer can reach a solution faster if one exists. One common way of doing this is to reduce the allowed degree of complexity in the produced program, which can be done by reducing the allowed nesting height of the statements.

This creates the problem of not being able to solve overly complex specifications, because they would require a more complex program than the above limitation imposes. To allow a solution to such problems while keeping the limitation, one can provide the algorithm with more abstractions. This research explores ways of doing this automatically, via extending the program from common parts of the solutions to simpler problems, before tackling a complex problem.

The following shows what the algoritm tries to do, and the expected result. It uses a grammar that could be the subset of a Lisp-like language's grammar (Racket?):

```
Starting Grammar
ListOrNumber -> 1 | 2 | 3 … 13
ListOrNumber -> x
ListOrNumber -> (times ListOrNumber ListOrNumber)
ListOrNumber -> (head ListOrNumber)
ListOrNumber -> (tail ListOrNumber)
ListOrNumber -> (cons ListOrNumber ListOrNumber) | nil

Give different sets of examples, termed tasks
breadth-first-search, max search depth = 4

Examples 1
[2, 4, 10] -> 12
[3, 5, 8] -> 15
[2, 3, 4] -> 9

Program 1
(times 3 (head (tail x))) [depth 4]

Examples 2
[2, 4, 10] -> 8
[3, 5, 8] -> 10
[2, 3, 4] -> 6

Program 2
(times 2 (head (tail x))) [depth 4]

Common Pattern - Grammar Extension
ListOrNumber -> second-item = (head (tail x))

Testing Examples
[2, 4, 10] -> [2, 4]
[4, 2, 8] -> [4, 2]
[8, 5, 13] -> [8, 5]

Expected Program with the extended grammar:
(cons (head x) (cons second-item nil)) [depth 3]
Expected program with the original grammar:
(cons (head x) (cons (head (tail x)) nil)) [depth 5]
```

This project is for my bachelors thesis at Delft University of Technology, Computer Science and Engineering.