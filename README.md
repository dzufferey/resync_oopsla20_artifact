# 424. Programming at the Edge of Synchrony (Artifact)

Documentation to reproduce the experiments from the paper "Programming at the Edge of Synchrony".

## Scope of the Artifact

This artifacts explain how to run ReSync and the other tools against which we compare.
To goal of the artifact is to reproduce the figures in Section 6 of the paper.
Some tools are available in newer versions since we originally ran the tests.
We try to use the more recent versions when possible.

### Software Setup

This repository only contains the explanation about how to install and run other tools, as well as scripts and configuration files to facilitate this task.

We have tested the tools with Debian Linux distributions.
As we use external project, we install them separately from their source to guarantee they have not been tampered.

PSync and ReSync have the same code base.
As Psync is a special case of ReSync, they share the same runtime.
PSync is just a specific set of progress condition in ReSync.
This is implemented in the file [`src/main/scala/psync/Round.scala`](https://github.com/dzufferey/psync/blob/master/src/main/scala/psync/Round.scala).
A `Round` is the PSync model and an `EventRound` is the ReSync model.
It is possible to get some of the benefit of ReSync with `Round` by overriding `expectedNbrMessages`.
We use that option when comparing PSync and ReSync.

### Hardware Setup

Running the experiments requires having access to 9 machines.
It is possible to run on fewer machines by running multiple processes per machines but this will affect the results.

The performance numbers will vary depending on the deployment (machines, network, etc.) and requires tuning some parameters.
However, the trends shown in the paper should be the same.
Their can be variability between test run so each test can be run a few time and the results averaged.
If you want to witness ReSync running the machines used to get the numbers in the paper, please contact Damien Zufferey (zufferey@mpi-sws.org) for a demonstration.


## Getting Started Guide

1. Install clusterssh (optional but really helpful to run the tests)
2. Install dependencies
3. Clone the artifact repository
4. Install PSync
5. Install LibPaxos3
6. Install etcd
7. Install Goolong
8. Install Bft-SMaRt

Except for clusterssh, all the other tools should be installed on all the machines running the tests.
clusterssh is installed on the machine the perform running the tests.

During the installation, we set some environment variables: `$RESYNC`, `$PSYNC`, `$LPAXOS`, `$ETCD`, `$GOOLONG`, and `$BFTS`.
These variables are important as the scripts running the experiments use them.

### Install clusterssh

Usually, running a test is done by issuing the same command to all the machines participating in the test.
`clusterssh` allows you to send commands to all the machines at the same time (or a subset of the machines).
This greatly helps running the tests.
```sh
sudo apt install clusterssh
```

Then put the addresses of the test machines in `.clusterssh/clusters`.
For instance, the file may contain
```
resync srv-76-164.mpi-sws.org srv-76-165.mpi-sws.org srv-76-166.mpi-sws.org srv-76-167.mpi-sws.org srv-76-168.mpi-sws.org srv-76-169.mpi-sws.org srv-76-117.mpi-sws.org srv-76-118.mpi-sws.org srv-76-119.mpi-sws.org
```
In the rest of this artifact, we will use these machines names as placeholder.

Then you can connect to all the machines with
```
cssh resync
```

From now on, you should connect to the test machines and the rest of the setup occurs there.

#### Recommended way to run commands

Installing the tools has to be done with on the 9 test machines.
During the installation, there will be _local test run_ and _distributed test run_.
The local test run check that the tools are installed properly by running everything on the same machine.
The distributed test runs the tool across machines.
This serves to test that the tools are configured properly and the machine can connect to each other.

Some tools requires an extra "client" to drive the test.
The main program is a replicated server which runs of all the machine and client makes request to evaluate the system throughput.
For such cases, the simplest is to open an extra ssh connection to one of the test machine (we recommend `REPLICA0`, see configuration below) and run the client there.


### Install dependencies

The tools we use have some external dependencies and we group their installation here.
Here are the command to install the dependencies.

* Utils:
  ```sh
  sudo apt install curl wget git zsh
  ```
* C: these are the dependencies for LibPaxos3.
  ```sh
  sudo apt install build-essential cmake libevent-dev libmsgpack-dev
  ```
* Java is needed by Bft-SMaRt:
  ```sh
  sudo apt install default-jdk ant
  ```
  We run our tests with OpendJDK 8 but it should work for higher versions.
* Scala is used by PSync.
  [sbt](https://www.scala-sbt.org/) takes care of building everything.
  ```sh
  echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
  sudo apt-get update
  sudo apt-get install sbt
  ```
* Go is needed for etcd and Goolong.
  etcd requires a recent version of go but [Goolong does not work with go 1.14](https://github.com/gleissen/goolong/issues/2).
  Therefore, we recommend using go version 1.13 manually:
  ```sh
  wget https://golang.org/dl/go1.13.14.linux-amd64.tar.gz
  tar -C /usr/local -xzf go1.13.14.linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/go/bin
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  ```

### Clone the artifact repo

```sh
git clone https://github.com/dzufferey/resync_oopsla20_artifact.git
cd resync_oopsla20_artifact
export RESYNC=$PWD
echo "export RESYNC=$PWD" >> ~/.bashrc
```

The last line adds the `RESYNC` environment variable to the `.bashrc` file.
So if you disconnect and reconnect to the machine the variable will always be defined.

#### Setting the addresses for the machines

The artifact contain scripts that help you run the tools.
These script needs to know about the addresses of the test machines that you use.

The script `$RESYNC/set_replicas.sh` performs this configuration step.

First, modify the script to insert the information about your machines.
The script contains `TODO` comments above the part you need to modify.

After you are done with the modifications, just run the script:
```sh
cd $RESYNC
./set_replicas.sh
```

To check that the script worked properly you can run
```sh
$RESYNC/findId.sh
```
The command should output the ID of the replica, a number between 0 and 8.

If you did an mistake, you can reset the state of the repo with `git checkout .` and then try again.

### Install PSync

This covers both ReSync and PSync.

1. __Building PSync.__
   ```sh
   git clone https://github.com/dzufferey/psync.git
   cd psync
   sbt compile
   sbt test:compile
   ./utils/generateClassPath.sh
   export PSYNC=$PWD
   echo "export PSYNC=$PWD" >> ~/.bashrc
   ```
   The hash of the commit we use is `3c03656e291794c34769234f358c84798c75f0fd`.
   (Obtained by running the command `git rev-parse HEAD`.)
2. __Local test run, part 1.__
   ```sh
   # from the psync folder
   ./test_scripts/testLV.sh
   ```
   The test runs for about 1 minute and the output should looks like
   ```
   running 3 LV replicas for 60 seconds
   stopping ...
   #instances = 211178, Δt = 58, throughput = 3641
   #instances = 211285, Δt = 58, throughput = 3642
   #instances = 211189, Δt = 58, throughput = 3641
   ```
   It is likely that the test will produce warnings like
   ```
   [Warning] @ TcpRuntime: Couldn't connect, trying again...
   [Warning] @ Algorithm: processPool is running low
   ```
   during the run and after `stopping ...` there can be outputs like
   ```
   [Warning] @ TcpRuntime: Tried to send packet to 1, but no channel was available.
   java.lang.AssertionError: assertion failed
   ```
   Warnings are harmless and serves as indication of places when the runtime can be improved (better resource management, graceful shutdown, etc.).

   On more recent version of java, you may see
   ```
   WARNING: An illegal reflective access operation has occurred
   WARNING: Illegal reflective access by com.esotericsoftware.kryo.util.UnsafeUtil (file:/home/zufferey/.cache/coursier/v1/https/repo1.maven.org/maven2/com/esotericsoftware/kryo-shaded/4.0.2/kryo-shaded-4.0.2.jar) to constructor java.nio.DirectByteBuffer(long,int,java.lang.Object)
   WARNING: Please consider reporting this to the maintainers of com.esotericsoftware.kryo.util.UnsafeUtil
   WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
   WARNING: All illegal access operations will be denied in a future release
   ```
   This can also be ignored.
   The library we use for serialization ([twitter chill](https://github.com/twitter/chill)) uses some deprecated features of the JVM.
3. __Local test run, part 2.__
   ```sh
   # from the psync folder
   ./test_scripts/testTempByzantine.sh
   ```
   The test runs for about 1 minute.
   Similar as before it can produce a fair amount of output and errors _after `stopping ...`_.
   This test checks that secure connection can be established between replicas.
   If this fails with errors related to java security, this can usually be fixed by editing the `.jvmopts` in the psync folder and adding the following lines:
   ```
   -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts
   -Djavax.net.ssl.trustStorePassword=changeit
   -Djavax.net.ssl.trustStoreType=JKS
   ```
4. __Distributed test run.__
   on the 9 test machines at the same time, run the following command:
   ```sh
   $RESYNC/psync/testTwoPhaseCommit.sh --conf $RESYNC/psync/default/9replicas-conf.xml
   ```
   This runs the two phase commit protocol.
   The tests automatically ends after a few minutes.


### Install LibPaxos3

To install LibPaxos3, we follow the instructions from https://bitbucket.org/sciascid/libpaxos/src/master/

1. __Building LibPaxos3.__
   ```sh
   git clone https://bitbucket.org/sciascid/libpaxos.git
   mkdir libpaxos/build
   cd libpaxos/build
   cmake ..
   make
   export LPAXOS=$PWD
   echo "export LPAXOS=$PWD" >> ~/.bashrc
   ```
   The hash of the commit we use is `d255f8b67a32d5e0ef43ac1a393b72cee23d8e0e`.
   (Obtained by running the command `git rev-parse HEAD`.)
2. __Local test run.__
   ```sh
   # from the libpaxos/build folder
   ./sample/proposer 0 ../paxos.conf > /dev/null &
   ./sample/acceptor 1 ../paxos.conf > /dev/null &
   ./sample/acceptor 2 ../paxos.conf > /dev/null &
   ./sample/client ../paxos.conf -p 0 &
   sleep 10; killall client proposer acceptor
   ```
   The last command let the processes run for 10 seconds and then kill them.
   The output should look like
   ```
   06 Aug 15:49:51. Connect to 127.0.0.1:8801
   06 Aug 15:49:51. Connect to 127.0.0.1:8802
   Connected to proposer
   06 Aug 15:49:51. Connected to 127.0.0.1:8800
   06 Aug 15:49:51. Connected to 127.0.0.1:8801
   06 Aug 15:49:51. Connected to 127.0.0.1:8802
   3239 value/sec, 2.37 Mbps, latency min 182 us max 1117 us avg 301 us
   3138 value/sec, 2.30 Mbps, latency min 210 us max 674 us avg 345 us
   3019 value/sec, 2.21 Mbps, latency min 232 us max 607 us avg 377 us
   3047 value/sec, 2.23 Mbps, latency min 236 us max 507 us avg 305 us
   3057 value/sec, 2.24 Mbps, latency min 236 us max 1059 us avg 338 us
   3061 value/sec, 2.24 Mbps, latency min 234 us max 617 us avg 317 us
   3043 value/sec, 2.23 Mbps, latency min 237 us max 569 us avg 316 us
   2935 value/sec, 2.15 Mbps, latency min 233 us max 545 us avg 326 us
   2982 value/sec, 2.18 Mbps, latency min 234 us max 1457 us avg 314 us
   3055 value/sec, 2.24 Mbps, latency min 224 us max 583 us avg 326 us
   [1]   Terminated              ./sample/acceptor 1 ../paxos.conf > /dev/null
   [2]   Terminated              ./sample/acceptor 2 ../paxos.conf > /dev/null
   [3]-  Terminated              ./sample/proposer 0 ../paxos.conf > /dev/null
   [4]+  Terminated              ./sample/client ../paxos.conf -p 0
   ```
3. __Distributed test run.__
   On the 9 test machine, run the server programs
   ```sh
   cd $RESYNC/libpaxos3
   ./run_replicas.sh -n 9
   ```
   On one of the machine, run the client program
   ```sh
   cd $RESYNC/libpaxos3
   ./run_client.sh -n 9
   ```
   The client produces an output which looks like
   ```
   07 Aug 09:19:01. Connect to 139.19.162.64:8800
   07 Aug 09:19:01. Connect to 139.19.162.65:8800
   07 Aug 09:19:01. Connect to 139.19.162.66:8800
   07 Aug 09:19:01. Connect to 139.19.162.67:8800
   07 Aug 09:19:01. Connect to 139.19.162.68:8800
   07 Aug 09:19:01. Connect to 139.19.162.69:8800
   07 Aug 09:19:01. Connect to 139.19.162.17:8800
   07 Aug 09:19:01. Connect to 139.19.162.18:8800
   07 Aug 09:19:01. Connect to 139.19.162.19:8800
   Connected to proposer
   07 Aug 09:19:02. Connected to 139.19.162.64:8800
   07 Aug 09:19:02. Connected to 139.19.162.65:8800
   07 Aug 09:19:02. Connected to 139.19.162.66:8800
   07 Aug 09:19:02. Connected to 139.19.162.67:8800
   07 Aug 09:19:02. Connected to 139.19.162.68:8800
   07 Aug 09:19:02. Connected to 139.19.162.69:8800
   07 Aug 09:19:02. Connected to 139.19.162.18:8800
   07 Aug 09:19:02. Connected to 139.19.162.19:8800
   07 Aug 09:19:02. Connected to 139.19.162.17:8800
   205 value/sec, 51.30 Mbps, latency min 86151 us max 608868 us avg 401983 us
   250 value/sec, 62.56 Mbps, latency min 240438 us max 517487 us avg 377810 us
   275 value/sec, 68.82 Mbps, latency min 332199 us max 409198 us avg 370590 us
   ...
   ```
   You can then stop the client and server (`CTRL+C`).

### Install etcd

1. __Building etcd.__
   We install etcd from source as the benchmarking tool for etcd does not come with the standard installation.
   The last version of etcd to build with go 1.13 is etcd 3.4.9.
   ```sh
   git clone https://github.com/etcd-io/etcd.git
   cd etcd
   git checkout tags/v3.4.9
   source build
   etcd_build
   tools_build
   export ETCD=$PWD
   echo "export ETCD=$PWD" >> ~/.bashrc
   ```
   The hash of the commit we use is `54ba9589114fc3fa5cc36c313550b3c0c0938c91`.
   (Obtained by running the command `git rev-parse HEAD`.)
2. __Local test run.__
   ```sh
   # from the etcd directory
   ./bin/etcd &
   # write,read to etcd
   ./bin/etcdctl --endpoints=localhost:2379 put foo bar
   ./bin/etcdctl --endpoints=localhost:2379 get foo
   killall etcd
   ```
   The `etcdctl` command should produce the following output:
   ```
   # ./bin/etcdctl --endpoints=localhost:2379 put foo bar
   OK
   # ./bin/etcdctl --endpoints=localhost:2379 get foo
   foo
   bar
   ```
3. __Distributed test run.__
   On the 9 test machine, run the server programs
   ```sh
   cd $RESYNC/etcd
   ./etcd_test_9.sh
   ```
   On one of the machine, run the benchmark program
   ```sh
   cd $RESYNC/etcd
   ./run_client.sh
   ```
   The benchmark produces an output which looks like
   ```
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
   INFO: 2020/08/07 10:28:48 parsed scheme: "endpoint"
   INFO: 2020/08/07 10:28:48 ccResolverWrapper: sending new addresses to cc: [{http://139.19.162.68:2379  <nil> 0 <nil>}]
    10000 / 10000 Booooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00% 1s

   Summary:
     Total:	1.4784 secs.
     Slowest:	0.2263 secs.
     Fastest:	0.0406 secs.
     Average:	0.1449 secs.
     Stddev:	0.0291 secs.
     Requests/sec:	6763.9660

   Response time histogram:
     0.0406 [1]	|
     0.0591 [5]	|
     0.0777 [14]	|
     0.0963 [1177]	|∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
     0.1149 [67]	|
     0.1334 [1632]	|∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
     0.1520 [2543]	|∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
     0.1706 [2879]	|∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
     0.1891 [1234]	|∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎
     0.2077 [402]	|∎∎∎∎∎
     0.2263 [46]	|

   Latency distribution:
     10% in 0.0906 secs.
     25% in 0.1311 secs.
     50% in 0.1439 secs.
     75% in 0.1651 secs.
     90% in 0.1799 secs.
     95% in 0.1844 secs.
     99% in 0.2045 secs.
     99.9% in 0.2127 secs.
   ```
   You can then stop the etcd servers (`CTRL+C`).

### Install Goolong

To install and run Goolong, we follow the information from https://github.com/gleissen/goolong/ and https://goto.ucsd.edu/~rkici/popl19_artifact_evaluation/.

1. __Building Goolong.__
   ```sh
   git clone https://github.com/gleissen/goolong.git
   cd goolong
   ```
   The hash of the commit we use is `2bc38024204f9747ed9818502c5df3d36b96dd7d`.
   (Obtained by running the command `git rev-parse HEAD`.)

   Before, we can build goolong we need to [make a small fix](https://github.com/gleissen/goolong/issues/1).
   Open the file `src/multipaxos/multipaxos.go` and on line 495, replace `Assign` by `Put`.
   Now we can build goolong.
   ```sh
   make
   export GOOLONG=$PWD
   echo "export GOOLONG=$PWD" >> ~/.bashrc
   ```
2. __Local test run.__
   running
   ```sh
   # in the goolong folder
   ./run_paxos.sh
   ```
   should produce an output which looks like:
   ```
   running multi paxos with 3 servers and a client ...
   make: Entering directory '/root/goolong'
   make: Nothing to be done for 'all'.
   make: Leaving directory '/root/goolong'
   Starting.
   node: waiting for connections
   Starting.
   node: waiting for connections
   Starting.
   node: waiting for connections
   Starting.
   node: waiting for connections
   Replica id: 0. Done connecting.
   Done starting.
   Starting.
   node: waiting for connections
   Replica id: 1. Done connecting.
   Done starting.
   Starting.
   node: waiting for connections
   Replica id: 0. Done connecting.
   Done starting.
   Waiting for connections...
   Replica id: 1. Done connecting.
   Done starting.
   Waiting for connections...
   Replica id: 2. Done connecting.
   Done starting.
   Replica id: 2. Done connecting.
   Done starting.
   Waiting for connections...
   Connecting to replicas..
   Done connecting to 0
   Accepted connection from: 127.0.0.1:40450
   Done connecting to 1
   Done connecting to 2
   Connected to replicas: readers are [0xc000012300 0xc000012360 0xc0000123c0] .
   Accepted connection from: 127.0.0.1:34124
   Accepted connection from: 127.0.0.1:60952
   Round took 4.9297561210000005
   Test took 4.929788226
   Successful: 5000
   Caught signal; exiting
   Caught signal; exiting
   Caught signal; exiting
   DONE !
   ```
3. __Distributed test run.__
   On the 9 test machine, run the server programs
   ```sh
   cd $RESYNC/goolong
   ./run_server.sh -n 9
   ```
   On one of the machine, run the benchmark program
   ```sh
   cd $RESYNC/goolong
   ./run_client.sh -n 9 -q 1000
   ```
   The client produces an output which looks like
   ```
   using config file /root/resync_oopsla20_artifact/goolong/info9.sh
   client: no process found
   running client
   /root/goolong/bin/client  -q 1000   srv-76-164.mpi-sws.org:7070 srv-76-165.mpi-sws.org:7070 srv-76-166.mpi-sws.org:7070 srv-76-167.mpi-sws.org:7070 srv-76-168.mpi-sws.org:7070 srv-76-169.mpi-sws.org:7070 srv-76-117.mpi-sws.org:7070 srv-76-118.mpi-sws.org:7070 srv-76-119.mpi-sws.org:7070
   Connecting to replicas..
   Done connecting to 0
   Done connecting to 1
   Done connecting to 2
   Done connecting to 3
   Done connecting to 4
   Done connecting to 5
   Done connecting to 6
   Done connecting to 7
   Done connecting to 8
   Connected to replicas: readers are [0xc00008a540 0xc000154000 0xc000194000 0xc00008a780 0xc000194240 0xc000194420 0xc00008a9c0 0xc0001181e0 0xc00008ac00] .
   Round took 6.483281643
   Test took 6.483313495
   Successful: 1000
   ```


### Install Bft-SMaRt

To install Bft-SMaRt, we follow the instructions from https://github.com/bft-smart/library

1. __Building Bft-SMaRt.__
   ```sh
   wget https://github.com/bft-smart/library/archive/v1.2.tar.gz
   tar -xzf v1.2.tar.gz
   cd library-1.2
   ant
   export BFTS=$PWD
   echo "export BFTS=$PWD" >> ~/.bashrc
   ```
   The MD5 sum of the downloaded archive is
   ```sh
   # md5sum v1.2.tar.gz
   4c6cbfa88192294ee5f64d66812a2702  v1.2.tar.gz
   ```
2. __Local test run.__
  - edit the configuration file `config/hosts.config` so it contains
    ```
    #server id, address and port (the ids from 0 to n-1 are the service replicas)
    0 127.0.0.1 11000
    1 127.0.0.1 11010
    2 127.0.0.1 11020
    3 127.0.0.1 11030
    ```
  - run the test:
    ```sh
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 0 &
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 1 &
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 2 &
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterServer 3 &
    sleep 10
    ./runscripts/smartrun.sh bftsmart.demo.counter.CounterClient 1001 1 1000 &
    sleep 10; killall java
    ```
    The test produce a fair amount of output related to the client invoking and increment counter operation and the replicas print their state (`---------- DEBUG INFO ----------`) just before exiting.
3. __Distributed test run.__
   On the 9 test machine, run the server programs
   ```sh
   cd $RESYNC/bft-smart
   ./run_server.sh -n 9
   ```
   On one of the machine, run the benchmark program
   ```sh
   cd $RESYNC/bft-smart
   ./run_client.sh
   ```
   The client produces an output which looks like
   ```
   Launching client 1001
   -- Connecting to replica 0 at /139.19.162.64:8800
   -- Channel active
   -- Connecting to replica 1 at /139.19.162.65:8800
   -- Channel active
   -- Connecting to replica 2 at /139.19.162.66:8700
   -- Channel active
   -- Connecting to replica 3 at /139.19.162.67:8800
   -- Channel active
   -- Connecting to replica 4 at /139.19.162.68:8800
   -- Channel active
   -- Connecting to replica 5 at /139.19.162.69:8800
   -- Channel active
   -- Connecting to replica 6 at /139.19.162.17:8800
   -- Channel active
   -- Connecting to replica 7 at /139.19.162.18:8800
   -- Channel active
   -- Connecting to replica 8 at /139.19.162.19:8800
   -- Channel active
   Warm up...
   Executing experiment for 50000 ops
   1001 // Average time for 50000 executions (-10%) = 2328.97341625 us 
   1001 // Standard desviation for 50000 executions (-10%) = 63.90399681790985 us 
   1001 // Average time for 50000 executions (all samples) = 2406.4735858999998 us 
   1001 // Standard desviation for 50000 executions (all samples) = 10154.83171698794 us 
   1001 // Maximum time for 50000 executions (all samples) = 1706460 us 
   All clients done.
   ```
   The servers also print performances measurements.

## Step by Step Instructions

We now explain how to reproduce the following

1. Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)
2. Byzantine test: ReSync against Bft-SMaRt (Figure 8b)
3. Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)
4. Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)
5. Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)

Below, we summarize the commands with the parameters as variables.
For instance, we write:
```sh
n=9 #in the range [3,9]
```
and use `$n` in the command.

To run the test on fewer machine, the simples is to set the appropriate test value, e.g., `n=3`.
When the number of machines changes, in the clusterssh `Hosts` menu it is possible to (de)activate a subset of the machines to which you are connected.


### Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)

#### ReSync

Running the tests is similar to the distributed test run but varying the number of replicas from 3 to 9.
The commands are:
```sh
# run on $n server (replicas with id 0 to n-1)
cd $RESYNC/psync
n=9 #in the range [3,9]
./testBatching.sh --conf batching/${n}replicas-conf.xml
```

__Computing the throughput.__
The output will contains the following toward the end of the output:
```
[Notice] @ BatchingClient: 0, #decisions = 97140600, Δt = 112, throughput = 867326 req/s. (9.925758361816406 MB/s)
```
The throughput can be read directly from that line.
The throughput can vary across replicas, replicate only count decision when they are part of the quorum.
The other replicas eventually learns about these decisions but do not not count them.
The replica with id 0 has the total count.

Because the system tries to progress as fast as possible, there can be slow replicas which always trails behind.
Such replicas will start producing messages like
```
[Notice] @ BatchingClient: 5 asking to 0 for decision 6359
```
Running the system with the additional options `--syncAll` can help but slowdowns the system a bit.


__Options.__
The configuration file specifies default options for a given test.
The main options which can be changed is the timeout.
It is possible to override the options specified in the configuration file by specifying them as argument *after* the `--conf` option.
For instance, `./testBatching.sh --conf batching/9replicas-conf.xml -to 50` overrides the timeout in the configuration and set it to 50 ms.
`./testBatching.sh --help` will print the list of all the options.
The timeout is the main option which influences the performance.
An lower timeout makes the system faster but less resilient to disturbances, e.g., sharing CPU with other processes, garbage collection, etc.


__Known Bugs.__
There are some bugs in ReSync and the tests.
These are mostly related to performances.
ReSync provides a round abstraction in which a fault-tolerant algorithm executes, but this is not all the code of the tests.
The complete code, e.g., distributed key-value store, manages client requests, forwards them to the consensus algorithm, processes the result of the algorithm, etc.
The interface between these two worlds can be tricky.
We are currently working on a new solution to clean this part so we did not yet fix these bugs.
(This part will get completely revamped in the next version of ReSync.)
* ReSync internally simulates clients producing requests.
  That part is independent of the actual requests processing.
  if the system cannot process the requests fast enough, it will keep accumulating requests and it will eventually take most of the memory.
  If you see such message as `java.lang.OutOfMemoryError: GC overhead limit exceeded`, you can reduce the rate at which request are generated by lowering the `--cr` options (see default value in configuration file).
  Alternatively, if the system seems to be starved you can try increasing this value.
* The part feeding requests to the consensus waits for the result of the previous decision.
  In some funny interleavings, this part can stop feeding new requests.
  The proposer is the replica 0 and an indication that it got stuck is the following line in the output:
  ```
  [Warning] @ BatchingClient: 0 did not get the data for N
  ```
  where `N` is a proposal number.
  If this happens, it is usually at the beginning of a test.
  We stop and restart such tests.
* Sometime Netty complains about memory leak:
  ```
  12:05:24.374 [nioEventLoop-1-1] ERROR io.netty.util.ResourceLeakDetector - LEAK: ByteBuf.release() was not called before it's garbage-collected.
  ...
  ```
  This does not happen enough to be a problem
  We are still trying to track down this bug.
  However, as it changes between versions of netty we are not sure where the problem is or if it even is one our side.

ReSync is a research prototype, so it is likely to contains many bugs.
Please report them to [our issue tracker](https://github.com/dzufferey/psync/issues).
Thank you.

#### PSync

PSync is run in a similar fashion as ReSync but with an extra flag (`--syncTO`) to force the PSync model of progress.
As PSync's progress is limited by the timeout.
The timeout value must be set quite low.
Here, are the command with timeout values we used for each number of replicas:
```sh
cd $RESYNC/psync
./testBatching.sh --conf batching/3replicas-conf.xml --syncTO -to 2
./testBatching.sh --conf batching/4replicas-conf.xml --syncTO -to 3
./testBatching.sh --conf batching/5replicas-conf.xml --syncTO -to 4
./testBatching.sh --conf batching/6replicas-conf.xml --syncTO -to 3
./testBatching.sh --conf batching/7replicas-conf.xml --syncTO -to 3
./testBatching.sh --conf batching/8replicas-conf.xml --syncTO -to 4
./testBatching.sh --conf batching/9replicas-conf.xml --syncTO -to 5
```

__Computing the throughput.__
Similar to ReSync.

__Options.__
Similar to ReSync, execept you need to keep `--syncTO`



#### LibPaxos3

Running the tests is similar to the distributed test run but varying the number of replicas from 3 to 9.
The commands are:

* servers:
  ```sh
  # run on $n server (replicas with id 0 to n-1)
  cd $RESYNC/libpaxos3
  n=9 #in the range [3,9]
  ./run_replicas.sh -n $n
  ```
* client:
  ```sh
  # run the client
  cd $RESYNC/libpaxos3
  n=9 #in the range [3,9]
  ./run_client.sh -n $n
  ```

__Computing the throughput.__
The client produces an output of resembling:
```
205 value/sec, 51.30 Mbps, latency min 86151 us max 608868 us avg 401983 us
```
Let the client run for a while, collect the `Mbps` values and average them.
Notice that the script output `Mbps` not `MB/s`  (bits not bytes).
To obtain the final throughput, the value in `Mbps` needs to be divided by 8.

__Options.__
The script `run_client.sh` runs the client making requests of 32KB (option `-v 32768`) with 100 outstanding requests (option `-o 100`).
The large request size matches the batching used by ReSync/PSync.
The number of outstanding requests allow LibPaxos3 to use bandwidth more efficiently.
Varying these options can increase or decrease the system throughput.

#### etcd

Running the tests is similar to the distributed test run but varying the number of replicas from 3 to 9.
The commands are:
* servers:
  ```sh
  # run on $n server (replicas with id 0 to n-1)
  cd $RESYNC/etcd
  n=9 #in the range [3,9]
  ./etcd_test_$n.sh
  ```
* client:
  ```sh
  # run the client
  cd $RESYNC/etcd
  ./run_client.sh
  ```

__Computing the throughput.__
In the client's output, look for the following.
```
Summary:
  ...
  Requests/sec:	868.2281
```
We can compute the throughput as `#req/s * reqSize / (1024 * 1024)`.
The default request size is 32KB.
In this case, we get a throughput of 14.3 MB/s.

__Options.__
The `run_client.sh` script has the following options:
* `-c`: number of connections (default: 10)
* `-t`: number of clients in parallel (default: 1000)
* `-o`: number of operations (default: 50000)
* `-s`: size of the request (default: 32768)

More information about etcd benchmarking is can be found there: https://github.com/etcd-io/etcd/blob/master/Documentation/op-guide/performance.md#benchmarks

#### Goolong

Running the tests is similar to the distributed test run but varying the number of replicas from 3 to 9.
The commands are:

* servers:
  ```sh
  # run on $n server (replicas with id 0 to n-1)
  cd $RESYNC/goolong
  n=9 #in the range [3,9]
  ./run_replicas.sh -n $n -b
  ```
* client:
  ```sh
  # run the client
  cd $RESYNC/goolong
  n=9 #in the range [3,9]
  ./run_client.sh -n $n -q 10000000
  ```

__Computing the throughput.__
To compute the throughput, we need to get the following two lines from the client output:
```
Round took 202.540084681
Test took 202.540147648
Successful: 10000000
```
The first line is the duration of the test and the last line is the number of requests.
A request in Goolong take 21 bytes of data over the wires.
We can compute the throughput in MB/s as `#request * 21 / #time / (1024 * 1024)`.
In this case, we get ~ 1MB/s

__Options.__
The `run_replicas.sh` script needs to run with `-b` to enable batching.
The `run_client.sh` script takes as parameter the number of requests.

### Byzantine test: ReSync against Bft-SMaRt (Figure 8b)

#### ReSync

```sh
# run on $n server (replicas with id 0 to n-1)
cd $RESYNC/psync
n=9 #in the range [4,9]
./testByzantine.sh --conf byzantine/${n}replicas-conf.xml
```

__Computing the throughput.__
Similar to ReSync.

__Options.__
Similar to ReSync.


#### Bft-SMaRt

Running the tests is similar to the distributed test run but varying the number of replicas from 4 to 9.
For the server, there is nothing special to do.
However, for the client there are options which influence the performances.
Here, we give the options that worked best for us.

The commands are:
* servers:
  ```sh
  cd $RESYNC/bft-smart
  n=9 #in the range [4,9]
  ./run_server.sh -n $n
  ```
* client:
  ```sh
  cd $RESYNC/bft-smart
  # for $n = 9
  ./run_client.sh -t 7 -o 10000 -s 2048
  # for $n = 8
  ./run_client.sh -t 12 -o 10000 -s 2048
  # for $n = 7
  ./run_client.sh -t 16 -o 8000 -s 4096
  # for $n = 6
  ./run_client.sh -t 13 -o 8000 -s 8192
  # for $n = 5
  ./run_client.sh -t 14 -o 8000 -s 16384
  # for $n = 4
  ./run_client.sh -t 16 -o 8000 -s 16384
  ```

__Options.__
The `run_client.sh` script has three options:
- `t`: the number of clients (threads) making request in parallel
- `o`: the number of operations per client
- `s`: the size of a request
Varying these options will affect the performances.

__Computing the throughput.__
When running the client, the server will print performance measurements periodically.
The important lines are:
```
Throughput = 1634.2539 operations/sec (Maximum observed: 1647.175 ops/sec)
```
From this, we compute the throughput in MB/s with the following formula: `#ops/sec * request_size / (1024*1024)`.
In that case if the client was
```sh
./run_client.sh -t 7 -o 10000 -s 2048
```
The request size is 2048 and we get a throughput of 3.3 MB/s.


### Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)

As the previous experiments, the scrips are in the `psync` folder of the artifact and are run with different number of machines:
```sh
# run on $n server (replicas with id 0 to n-1)
cd $RESYNC/psync
n=9 #in the range [3,9]
```

The scripts for the two versions of two phase commit with different progress conditions are:
* Wait all:
  ```sh
  ./testTwoPhaseCommit.sh --conf default/${n}replicas-conf.xml --all
  ```

* Fail fast:
  ```sh
  ./testTwoPhaseCommit.sh --conf default/${n}replicas-conf.xml
  ```

__Computing the latency.__
The replica with id 0 produces an output of the form:
```
...
replica 0 starting with false
dt = 2
replica 0 decided Some(false)
replica 0 starting with false
dt = 3
replica 0 decided Some(false)
...
```
The `dt` is the latency measured by the coordinator process.
We take the average of these values.


### Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)

As the previous experiments, the scrips are in the `psync` folder of the artifact and are run with different number of machines:
```sh
# run on $n server (replicas with id 0 to n-1)
cd $RESYNC/psync
n=9 #in the range [3,9]
```

The commands for the different configurations are:
* SW Quorum:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 20 --syncQuorum
  ```
* SW All:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 20 --syncAll
  ```
* SW TO:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 20 --syncTO
  ```
* Ser Quorum:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 1 --syncQuorum
  ```
* Ser All:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 1 --syncAll
  ```
* Ser TO:
  ```sh
  ./testSimplePaxos.sh --conf default/${n}replicas-conf.xml -rt 1 --syncTO
  ```

The tests are designed to put stress on the runtime and the system can output messages of the form:
```
[Warning] @ Algorithm: processPool is running low
```
These messages are expected.

__Computing the throughput.__
At the end of the test, the replicas print
```
#instances = 387091, Δt = 64, throughput = 6048
```
The throughput there is in requests per second.
It needs to be divided by 1000 to match the request per millisecond reported in the paper.

### Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)

In this test we use the 9 machines but vary the timeout:
```sh
# run on 9 server
cd $RESYNC/psync
t=1 # in the set {1,2,3,5,10,20,50}
```

The commands for the different configurations are:
* SW TCP:
  ```sh
  ./testSimplePaxos.sh --conf default/9replicas-conf.xml --protocol TCP -rt 20 -to $t
  ```
* SW UDP
  ```sh
  ./testSimplePaxos.sh --conf default/9replicas-conf.xml --protocol UDP -rt 20 -to $t
  ```
* Ser TCP
  ```sh
  ./testSimplePaxos.sh --conf default/9replicas-conf.xml --protocol TCP -rt 1 -to $t
  ```
* Ser UDP
  ```sh
  ./testSimplePaxos.sh --conf default/9replicas-conf.xml --protocol UDP -rt 1 -to $t
  ```

__Computing the throughput.__
Similar to the previous test.


## Scripts used to produce the plots in the paper

The `figures` folder contains the scripts that produce the figures in the paper.

Making the figures require gnuplot and inkscape:
```sh
sudo apt install gnuplot inkscape
```

Each figures has two files:
* `$NAME.dat` contains the data
* `$NAME.gnuplot` is the gnuplot script to produce the figures

The script `mk_figs.sh` produces the plots (`$NAME.pdf`) which are used in the paper.

The filenames match the figures in the paper as follows:
* `lp3_gl_ed_z` is Figure 8a;
* `bft` is Figure 8b;
* `latency_2pc` is Figure 9a;
* `progress_lv` is Figure 9b;
* `timeout` is Figure 9c.

