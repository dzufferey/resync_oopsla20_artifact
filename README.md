# 424. Programming at the Edge of Synchrony

Documentation to reproduce the experiments from the paper "Programming at the Edge of Synchrony"

## Scope of the Artifact

This artifacts explain how to run ReSync and the other tools against which we compare.

### Software Setup

This repository only contains the explanation about how to install and run other tools, as well as scripts and configuration files to facilitate this task.

We have tested the tools with Debian and Ubuntu Linux distributions.
As we use external project, we install them separately from their source to guarantee they have not been tampered.

### Hardware Setup

Running the experiments requires having access to 9 machines.
It is possible to run on fewer machines by running multiple processes on the same machine but this will affect the results.

The performance numbers will vary depending on the deployment and requires tuning some parameters.
If you want to witness ReSync running the machines used to get the numbers in the paper, please contact Damien Zufferey (zufferey@mpi-sws.org) for a demonstration.

PSync and ReSync have the same codebase.
As Psync is a special case of ReSync, they share the same runtime.
PSync is just a specific set of progress condition in ReSync.
This is implemented in the file `src/main/scala/psync/Round.scala`.
A `Round` is the PSync model and an `EventRound` is the ReSync model.
It is possible to get some of the benefit of ReSync with `Round` by overriding `expectedNbrMessages`.
We will use that option when comparing PSync and ReSync.


## Getting Started Guide


1. Install clusterssh (optional but really helpful later)
2. Clone the artifact repo
3. Install PSync
4. Install LibPaxos3
5. Install etcd
6. Install Goolong
7. Install Bft-SMaRt

Except for clusterssh, all the other tools should be installed on all the machines running the tests.
clusterssh is installed on the machine the perform running the tests.

### Install clusterssh

Usually, running a test is done by issuing the same command to all the machines participating in the test.
`clusterssh` allows you to send commands to all the machines at the same time (or a subset of the machines).
This greatly helps running the tests.
```sh
sudo apt install clusterssh
```

Then put the addresses of the machines you will use in `.clusterssh/clusters`.
For instance, the file may contain
```
resync srv-76-164.mpi-sws.org srv-76-165.mpi-sws.org srv-76-166.mpi-sws.org srv-76-167.mpi-sws.org srv-76-168.mpi-sws.org srv-76-169.mpi-sws.org srv-76-117.mpi-sws.org srv-76-118.mpi-sws.org srv-76-119.mpi-sws.org srv-76-120.mpi-sws.org
```

Then you can connect to all the machines with
```
cssh resync
```

From now on, you should connect to the test machines and the rest of the setup occurs there.

### Clone the artifact repo

```sh
git clone https://github.com/dzufferey/resync_oopsla20_artifact.git
cd resync_oopsla20_artifact
export RESYNC=$pwd
echo "export RESYNC=$pwd" >> .bashrc
```

The last line adds the `RESYNC` environment variable to the `.bashrc` file.
So if you disconnect and reconnect to the machine the variable will always be defined.


### Install PSync

This covers both ReSync and PSync.

... work around for security cert on debian
... java, sbt, generateClassPath.sh, generateCerts.sh, local test, distributed test


TODO give md5sum/hash of commits files

### Install LibPaxos3

To install LibPaxos3, we follow the instructions from https://bitbucket.org/sciascid/libpaxos/src/master/

1. installing the dependencies: gcc make cmake libevent msgpack
    ```sh
    sudo apt install build-essential cmake libevent-dev libmsgpack-dev
    ```
2. building LibPaxos3
    ```sh
    git clone https://bitbucket.org/sciascid/libpaxos.git
    mkdir libpaxos/build
    cd libpaxos/build
    cmake ..
    make
    ```
3. local test run
    ```sh
    cd libpaxos/build
    ./sample/acceptor 0 ../paxos.conf > /dev/null &
    ./sample/acceptor 1 ../paxos.conf > /dev/null &
    ./sample/proposer 0 ../paxos.conf > /dev/null &
    ./sample/learner ../paxos.conf > learner.txt &
    ./sample/client 127.0.0.1:5550 1
    ```
4. distributed test run
   TODO ...

### Install etcd

1. install dependencies:
   ```sh
   sudo apt install curl golang
   ```
   etcd requires a fairly recent version of go.
   If you use debian stable, you need to install go manually by following the instructions at [https://golang.org/doc/install]().
2. install etcd following the instructions at [https://github.com/etcd-io/etcd/releases]().
   TODO which version ...
3. local test run
   TODO ...
4. distributed test run
   TODO ...

### Install Goolong

To 

repo https://github.com/gleissen/goolong/
and instructions https://goto.ucsd.edu/~rkici/popl19_artifact_evaluation/

1. install zsh and make:
   ```sh
   sudo apt install zsh make
   ```
2. install go using your package manager or following the instructions at [https://golang.org/doc/install]()
   ```sh
   sudo apt install golang
   ```
3. clone and build goolong
   ```sh
   git clone https://github.com/gleissen/goolong.git
   cd goolong
   make
   ```
4. local test run
   ```
   ./run_paxos.sh
   ```
   should produce an ouput along the lines of
   ```
   FIXME
   ```
5. distributed test run.
   for this test, we will create a few configuration and helper scripts.

TODO ...
info[3-9].sh
run_server.sh
run_client.sh


### Install Bft-SMaRt

To install Bft-SMaRt, we follow the instructions from https://github.com/bft-smart/library

1. Install dependencies
   ```sh
   sudo apt install default-jdk ant wget
   ```
2. Download and ant Bft-SMaRt
   ```sh
   wget https://github.com/bft-smart/library/archive/v1.2.tar.gz
   tar -xzf library-1.2.tar.gz
   cd library-1.2
   ant
   ```
3. local test run
  - edit the configuration file `config/hosts.config` so it contains
    ```
    #server id, address and port (the ids from 0 to n-1 are the service replicas)
    0 127.0.0.1 11000
    1 127.0.0.1 11010
    2 127.0.0.1 11020
    3 127.0.0.1 11030
    ```
  - across 4 different console run the following (1 command per console):
    ```sh
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 0
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 1
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 2
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 3
    ```
  - run the client:
    ```
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterClient 1001 1 1000
    ```
    TODO what the output should look like
4. distributed test run
   TODO ...

## Step by Step Instructions

We now explain how to reproduce the following

1. Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)
2. Byzantine test: ReSync against Bft-SMaRt (Figure 8b)
3. Expressivness of ReSync compared to PSync (Table 1)
4. Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)
5. Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)
6. Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)

TODO for each test
- how to run (configuration files, scripts)
- how to interpret the output (compute throughput, etc.)
- what parameters can be tweaked

### Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)

#### ReSync

#### PSync

#### LibPaxos3

#### etcd

#### Goolong


### Byzantine test: ReSync against Bft-SMaRt (Figure 8b)

#### ReSync

#### Bft-SMaRt


### Expressiveness of ReSync compared to PSync (Table 1)


### Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)


### Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)


### Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)


## Caveats

Different Replicas may show different results ...
Timeouts ...
