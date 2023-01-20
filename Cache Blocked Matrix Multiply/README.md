# Lab 0: Warming Up

The purpose of this lab is to help you set-up and familiarize yourself with the tools that we will be using this semester. We have split this README in to four sections. We expect you to complete all of them and recommend tackling them in order.

1. [General Class Setup](#user-content-general-class-setup)
2. [Debugging with Valgrind Exercise](#user-content-debugging-with-valgrind-exercise)
3. [Cache Blocked Matrix Multiply Exercise](#user-content-cache-blocked-matrix-multiply-exercise)
4. [Collaboration, Submission, and Grading](#user-content-collaboration-submission-and-grading)

## General Class Setup

While not required, we provide the following VMs that closely mimic our cluster environment:

[Ubuntu VM - x64](https://www.dropbox.com/s/l9oosvauwz923sf/CSE6220_Fall2022_Lab_x64.ova?dl=0)

[Ubuntu VM - arm64](https://www.dropbox.com/s/z62zuufgzshp3fq/CSE6220_Fall2022_Lab_arm64.pvmp?dl=0)

These modules should be loadable into VirtualBox or VMware for x64 or Parallels for ARM64.

The username/password is lab/lab.

**IMPORTANT:** If you haven't run an Ubuntu guest machine on a Windows host machine, you may not have experienced its unique joys yet. `dos2unix` is your friend. It is preinstalled for you and can be used with `dos2unix some_file.sh`

### Obtaining the Starter Code

You should feel free to setup the directory structure as you wish, but the for the purpose of this lab, we will assume that you have a single top-level directory named `oms-hpc-labs` and that each individual lab will have a directory inside of this one.

First, make the top-level directory for the course and make it your working directory:
```sh
    mkdir oms-hpc-labs
    cd oms-hpc-labs
```

### Use git to Clone the Project Repo

Next, you will use git to obtain this `README` and the starter code for this assignment. The code is hosted on [Georgia Tech's GitHub server](https://github.gatech.edu/omscse6220), which requires authentication. Please run the following command (you will be asked for your GT credentials):

```sh
    git clone https://github.gatech.edu/omscse6220/lab0fa22.git
```

which will download the starter code for the assignment into a folder named `lab0fa22` (adjusted per semester even if README is not updated).

Depending on your environment, you may see the following error:

```sh
   Cloning into 'lab0fa22'...
    fatal: unable to access 'https://github.gatech.edu/omscse6220/lab0fa22.git/': server certificate verification failed. CAfile: /etc/ssl/certs/ca-certificates.crt CRLfile: none
```

If you do, you'll need to install some SSL certificates by executing the following sequence of three (3) commands:

```sh
   echo -n | openssl s_client -showcerts -connect github.gatech.edu:443 2>/dev/null \
           | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > github.gatech.edu.crt
		   
   sudo cp github.gatech.edu.crt /usr/local/share/ca-certificates/github.gatech.edu.crt

   sudo update-ca-certificates 
```

This example assumes you're running on Ubuntu (like our class VM). Other systems may need slight adjustments.

Assuming no issues, you will need to re-run the clone command:

```sh
    git clone https://github.gatech.edu/omscse6220/lab0fa22.git
```

> NOTE: Please make sure if you use your own code repository that it is kept **private**.

<hr />

## Debugging with Valgrind Exercise

In the past, some students have arrived at this course with minimal or no experience using Valgrind - which is a handy tool for debugging memory issues in your code. As such, we put together 6 short exercises to bring you up to speed. Instructions for each exercise can be found in a comment in `student/valgrindN.cpp` where N is 1-6. 

In theory, you can complete these exercises without reading the Valgrind output, but don't cheat yourself! The situations you'll be using Valgrind for in later labs will be much more complex. It will be much easier to learn the tool in these arbitrarily small exercises.

### Testing Your Solutions

- From `lab0` directory
- `make valgrind`. If you want to compile just one exercise, targets are provided in the form of `make valgrindN`
- To run the program with Valgrind, use `valgrind flags /path/to/executable`. For example: `valgrind /bin/valgrind1`.
- The flags we use in grader script (**valgrind_grader.sh**) are as follows: `valgrind --leak-check=full --error-exitcode=1 --tool=memcheck --track-origins=yes --errors-for-leak-kinds=definite --show-leak-kinds=definite ./bin/exercise1`.
- While we set up the flags to be ready to use for this lab, we have not done so for the other labs (yet). We recommend familiarizing yourself with the manual by using either `man valgrind` or checking [https://valgrind.org/docs/manual/manual.html].

### Memory Management Primer

The following list is a non-exhaustive list of things to keep an eye out for while debugging.

- **Memory Leaks:** When you allocate memory with functions such as `malloc` or keywords such as `new`, you must free them before the program exits or the program will leak memory. Modern operating systems do eventually clean them up, but that's no excuse to be sloppy - especially since you don't control this process and it may have unexpected performance implications.
  - [https://en.wikipedia.org/wiki/Memory_leak#Consequences]
- **Unitialized Variables:** When you first initialize memory, the C/C++ spec states that it's initial values shall be indeterminant. This means that it will be initialized to whatever happened to be in that memory location before your code run, so the chances of it being what you expected are pretty slim. There's a couple of ways to address this issue, but try looking first at either [calloc](https://en.cppreference.com/w/c/memory/calloc) or [memset](https://en.cppreference.com/w/cpp/string/byte/memset).
- **Buffer Overflow:** C/C++ does not have a built in mechanism to prevent you from writing past the bounds of an array. As you might imagine, writing to the wrong variables or memory location can cause some tricky to debug issues.
- **Operator Precendence:** When and how you dereference pointers can be tricky. When in doubt, paren(thesis) it out.
- **Segmentation Fault:** This is probably the most common issues among students in this class. A good definition of a segmentation fault can be found on [Wikipedia](https://en.wikipedia.org/wiki/Segmentation_fault#Overview). The most germane portion is copied here: `A segmentation fault occurs when a program attempts to access a memory location that it is not allowed to access, or attempts to access a memory location in a way that is not allowed (for example, attempting to write to a read-only location, or to overwrite part of the operating system).`
- **Sizeof and Pointers:** Using `sizeof` with pointers won't always result in what you expect. You should ask yourself two questions when using `sizeof`.
  1. Does it match the size I was expecting?
  2. Is `sizeof` even appropriate in this case?

<hr />

## Cache Blocked Matrix Multiply Exercise

To make sure that your environment is working and that you are able to connect the the instructional HPC cluster, we ask you to complete a simple exercise.

In the first few lectures, we covered memory hierarhcies in which we learned that CPUs have fast memory, or caches, that are used to augment the slower main memory. Caches are much smaller in size but faster to access in comparison to main memory and are used to temporarily store data that may be re-used during the course of a program's execution.

You will implement a matrix-matrix multiply program that will try to take advantage of the cache available on the PACE cluster to improve performance.

A naive matrix-matrix multiply implementation is provided as a reference in **student/mm.c**. To compile and run this code, do the following:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.bash}
  # Compile
  make mm

  # Run the program
  # ./mm <N> <K> <M>
  ./mm 64 64 64 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You should see the following:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N: 64 K: 64 M: 64
Timer: gettimeofday
Timer resolution: ~ 1 us (?)
Naive matrix multiply
Done
time for naive implementation: 0.002181 seconds

Cache-blocked matrix multiply
Done
time for cache-blocked implementation: 0.002181 seconds
SUCCESS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The program just computed **C[N][M] += A[N][K] * B[K][M], where N = M = K = 64** using the naive implementation. 

1. Implement a cache-blocked version of matrix-matrix multiply. This is essentially a blocked/tiled implementation where you compute the matrix in smaller sub-block increments. In your implementation, make sure that the size of the sub-block can be varied. Do **not** modify the function prototype.

2. Try varying the block size and measure the performance of your code in
terms of the time comparison.

### Testing Your Solution

We provide an automatic grading script (**mm_grader.sh**) that will test your solution against various pre-defined problem sizes. You can run this script as many times as you would like.

The provided tests will constitute a significant portion of your grade. We will re-run them after the deadline on our end.

You may also find the following tools useful:

* GDB (check [http://www.gdbtutorial.com/])
* Valgrind (check the earlier section in this lab, but also [https://valgrind.org/docs/manual/quick-start.html])

### Performance Results

In this class, your performance analysis should be performed on the PACE cluster. You can find more information about the cluster on the [PACE website](http://pace.gatech.edu/). In particular, the [User Resources](https://pace.gatech.edu/user-resources) pages might be useful for you. This is the same environment that we will perform grading on.

1. Copy over the code from this repository to a folder on the cluster.

   ```sh
      # Makes a directory on the cluster to hold this lab:
      ssh [your_gatech_name]@coc-ice.pace.gatech.edu mkdir -p oms-hpc-labs/lab0fa22
	  
	  # Copies your local files to the cluster
      scp -r * [your_gatech_name]@coc-ice.pace.gatech.edu:oms-hpc-labs/lab0fa22
   ```
   
2. Login to one of the head nodes of the cluster via ssh.

   ```sh
       ssh [your_gatech_name]@coc-ice.pace.gatech.edu
   ```
   
3. From the folder to which you copied the code (in the above examples, `oms-hpc-labs/lab0fa22`), run

   ```sh
       qsub performance.pbs
   ```
   
   which will submit jobs to the queue.  You may check the status of your job with the `qstat` command.
   
   > Note: Take a second to inspect the job script, `performance.pbs`. You might wish to seek out Torque documentation to try to understand its contents, particularly the `#PBS` options; the remainder of the file consists of compile commands and running the program with a preset matrix size.
   
4. Your results will appear in the output file of the form `job.*.out`. (It may take a minute to appear once the job is complete.)

<hr />

## Collaboration, Submission, and Grading

### Collaboration

For this lab, and strictly for this lab, you may collaborate in the manner described below. For other labs, please follow whichever instructions are given there.
1. **YOU MAY** ask other students what a specific Valgrind error message indiciates, discuss the issue at a whiteboard level, and whiteboard level approaches for solving the issue.
2. **YOU MAY NOT** share the code for an actual solution. Please don't make us involve OSI over a warmup lab.

### Submission

Lab submissions for this class will be through Canvas under the appropriate assignment.

For your submission, please zip up the following files without any extra (sub)directories:

```sh
   mm.c
   valgrind1.cpp
   valgrind2.cpp
   valgrind3.cpp
   valgrind4.cpp
   valgrind5.cpp
   valgrind6.cpp
```

Do **not** submit or modify any other files. Do **not** submit your student directory with your files inside as a zip. We just want all c/cpp files for the matrix multiply and Valgrind exercises in one zip without any extra (sub)directories. Doing otherwise breaks our grading scripts, which means our turnaround time for grading will be slower. **IMPORTANT: We will deduct a nominal number of points if you do not follow the above instructions.**.

### Grading

Your grade on this lab will consist of the following:

* Valgrind: Successfully passing the exercise graders.
* Matrix Multiply: Successful compilation.
* Matrix Multiply: Public/private correctness.
* Matrix Multiply: Performance score.

> NOTE: You have to pass correctness in order to be considered for a performance score.

The point totals of each are listed in the forum announcement post.
