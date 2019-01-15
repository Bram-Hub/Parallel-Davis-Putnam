# Parallel Davis Putnam
## Authors
2015:
Matthew Holmes

## About
Compilation:
  Serial: Straight forward, in my case:
            g++ -Wall main.cpp
            
  OpenMP: To compile use the -fopenmp flag ex, NOTE: main.cpp was the first iteration, for the best performance compile 6.cpp:
            g++ -fopenmp main.cpp
            
  CUDA: Assuming your CUDA toolkit is installed properly, compile with:
            nvcc main.cu
          Mixed: this was an experiment in order to attempt to use both CUDA and OpenMP. There is no guarantee that it works properly, but to compile:
                nvcc -Xcompiler -fopenmp mixed.cpp
                
Usage: In order to use all of these, one argument is needed, which is the input file to be read ex:
        ./a.out input.txt

Input files: See input.txt for an example input. Essentially, literals are integers seperated by spaces, negation is equivalent to not.
             Each new line is a new set of literals.
             
Other notes: All three formats are currently set to export their speeds to a csv file, I used this to grab large output data in order to get a stable average.
