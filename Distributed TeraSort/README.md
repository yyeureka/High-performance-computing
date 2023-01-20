# Lab 3: TeraSort -- Final Project

In this lab, your task is to implement a distributed sorting algorithm along the lines discussed in the lesson videos.  You will be writing your program using the [Chapel programming language](https://chapel-lang.org/docs/1.27/index.html).  Your algorithm design should be based on the assumption that the data will *not* fit in the physical memory of any one computer in your cluster but that it *will* fit in the union of all the physical memories.  This assumption makes your task slightly different from classical 
[distributed disk sorting benchmarks](http://sortbenchmark.org/), but many of the same principles apply.

## Getting Started
Begin by obtaining the starter code from the github repository.

<pre><code>
    git clone https://github.gatech.edu/omscse6220/lab3fa22.git
</code></pre>

Note that this is the [GT github server](https://github.gatech.edu), so you will need to authenticate with your GT credentials.

Optionally, you may choose use a git hosting service for your code.  As always, please **do not make your repository public** on Github or another git hosting service.  Anyone will be able to see it.  If you feel the need to use a hosting service for your project, please keep your repository private.  Your GT account allows you to create free private repositories on [the GT github server](https://github.gatech.edu).

The Chapel documentation provides an [excellent resource](https://chapel-lang.org/docs/1.27/primers/learnChapelInYMinutes.html) to get up to speed on using the language. Many of the features of the language will not be required to complete this project, since tasks like distributing the data across the locales have already been implemented for you.

## Updating the course VM
This lab uses a cutting edge version of Chapel that was released after the course VM was built.

You can update to the correct version with the provided script:

```sh
   ./chapel-update.sh
```

To simulate the execution of multiple locales (nodes) on a single machine, Chapel will launch multiple runtimes. To avoid the runtimes each contending for exclusive use of the system, when doing development on a single machine (either bare-metal or in the course VM), you will need to set the following environment variable:

<pre><code>
export CHPL_RT_OVERSUBSCRIBED=yes
</code></pre>

Note that since PACE interactive sessions correctly spawn Chapel runtimes on the provided number of nodes, you do *not* need to set this environment variable when working on the cluster.

## Programming
The data type you will sorting is similar to the one used in [Hadoop's Terasort benchmark](https://hadoop.apache.org/docs/current/api/org/apache/hadoop/examples/terasort/package-summary.html#package_description).  It consists of a 10-byte key and an 88-byte value.  Procedures for input/output and comparison of these records are provided for you in the **terarec.chpl** file in the *utils* directory.  Your only task is to complete the implementation of the terasort function, which has the signature

<pre><code>
proc terasort(ref keys, ref values, ref keys_out, ref values_out, ref counts_out)
</code></pre>

Here, keys and values are the data initially stored in memory as 2D arrays distributed across the participating Locales.  The remaining parameters are for return values.  The arrays keys_out and values_out reference allocated space in which to store each node's sorted keys and values within the whole.  Because space has been provided to you, the counts_out array stores the number of logical records (key-value pairs) which are local to each Locale. Thus, the data returned to Locale's slice of keys_out and values_out represents the sorted sequence with length counts_out[here.id].

This function can be found in **terasort.chpl** in the *student* directory. An example of the function's usage can be found in the **terasort_main.chpl** in *utils*.

Your code is expected to work with up to 8 nodes and 4 cores per node.

To facilitate the development of your distributed sorting algorithm, we provide a port of the *single-threaded* glibc qsort in Chapel, which works with the key and value arrays given to you in **terasort_main.chpl**. You are not required to use this sorting algorithm, and are encourage to develop your own faster (*parallel?*) sorting algorithms.

**Note** that Chapel does provide a parallel Radix sort. The data types we have provided do not work with this sort out of the box; nonetheless, any attempt to repackage the data to use the built-in parallel Radix sort as your entire sorting algorithm will result in a score of 0 on this assignment.

## First-Time Cluster Setup ##

Chapel spawns runtimes on the nodes allocated to your PACE job by using passwordless ssh to quickly open up connections to the other nodes. Before running your first Chapel programs on PACE, please run the following command to allow Chapel to open ssh sessions inside PACE:

<pre><code>
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
</code></pre>

## Testing Your Code and Measuring Performance
Performance tests will be a large part of your evaluation. You are encouraged share your ideas and results on the discussion forum.

The programs to generate and validate the unsorted and sorted data, respectively, are provided in C source files, to be executed with MPI as detailed below. The concept of a Locale in Chapel is distinct from the concept of a Process in MPI, so to make sure you are generating data correctly, ensure that you are passing the same *number* of processes to MPI as *Locales* you wish to use in Chapel. In the example below, we run 4 MPI processes which each write 10,000 records to disk for a total of 40,000 records. We then run terasort on 4 separate Locales, ensuring that the total number of records generated by MPI is divisible by the number of hardware nodes that will be utilized by Chapel. 

An example how to check the correctness of your code locally would be:
<pre><code>
$ make clean
$ make all
$ mpirun -np 4 ./teragen -c 10000
$ ./terasort -nl 4
$ mpirun -np 4 ./teravalidate
</code></pre>

We've also included the *terametrics* utility to assist with performance testing:
<pre><code>
$ make clean
$ make teragen terametrics
$ mpirun -np 4 ./teragen -c 10000
$ ./terametrics -nl 4
</code></pre>

The following OpenPBS jobs and interactive sessions are provided for your testing and development on the cluster:

* metrics.pbs (multiple nodes and cores - 8x4)
* correctness.pbs (runs ./grader.sh from within a PBS job on a 4x4 allocation)
* pace_interactive_more_cores.sh (multiple nodes and cores - 2x4 - you will need to source *pace_env.sh* like prior labs)
* pace_interactive_more_nodes.sh (multiple nodes and cores - 4x2 - you will need to source *pace_env.sh* like prior labs)

To ensure fair allocation of resources among students, we ask that you limit the usage of any number of nodes greater than 4 to PBS jobs *only*. You are free to create your own PBS jobs to test other combinations of node and core count, and may use metrics.pbs and correctness.pbs as references for these jobs.

You can get the usage of every generated executable file (e.g. teragen, terasort, teravalidate, terametrics) by running `./tera[xx] -h`.

## Submission

Lab submissions for this class will be through Canvas under the appropriate assignment.

The file you need to submit for this lab is:

```sh
   terasort.chpl
```
This file should exist in the **student** directory of your lab folder.

Do **not** submit or modify any other files.

## Grading

Your grade on this lab will consist of the following:

* Successful compilation
* Provided test cases
* Additonal test cases
* Performance score

The point totals of each are listed in the forum announcement post.
