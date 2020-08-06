# 424. Programming at the Edge of Synchrony

Documentation to reproduce the experiments from the paper "Programming at the Edge of Synchrony".

## Scope of the Artifact

This artifacts explain how to run ReSync and the other tools against which we compare.

TODO we try to use the latest available version of the tools against which we compare.

TODO scripts for the plots

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
This is implemented in the file [`src/main/scala/psync/Round.scala`](https://github.com/dzufferey/psync/blob/master/src/main/scala/psync/Round.scala).
A `Round` is the PSync model and an `EventRound` is the ReSync model.
It is possible to get some of the benefit of ReSync with `Round` by overriding `expectedNbrMessages`.
We will use that option when comparing PSync and ReSync.


## Getting Started Guide


1. Install clusterssh (optional but really helpful later)
2. Install dependencies
3. Clone the artifact repo
4. Install PSync
5. Install LibPaxos3
6. Install etcd
7. Install Goolong
8. Install Bft-SMaRt

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
resync srv-76-164.mpi-sws.org srv-76-165.mpi-sws.org srv-76-166.mpi-sws.org srv-76-167.mpi-sws.org srv-76-168.mpi-sws.org srv-76-169.mpi-sws.org srv-76-117.mpi-sws.org srv-76-118.mpi-sws.org srv-76-119.mpi-sws.org
```
In the rest of this artifact, we will use these machines names as placeholder.

Then you can connect to all the machines with
```
cssh resync
```

From now on, you should connect to the test machines and the rest of the setup occurs there.

### Install dependencies

The tools we use have some external dependencies and we group their installation here.
Here are the command to intall the dependencies.

* Utils:
  ```sh
  sudo apt install curl wget git zsh
  ```
* C: these are the dependencies for LibPaxos3.
  ```sh
  sudo apt install build-essential cmake libevent-dev libmsgpack-dev
  ```
* Java: Bft-SMaRt and PSync need Java
  ```sh
  sudo apt install default-jdk ant
  ```
* Scala: PSync needs scala on to of java. [sbt](https://www.scala-sbt.org/) takes care of building everything.
  ```sh
  echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
  sudo apt-get update
  sudo apt-get install sbt
  ```
* Go is needed for etcd and Goolong
  etcd requires a fairly recent version of go.
  If you use Ubuntu 20.04, you can do
  ```sh
  sudo apt install golang
  ```
  If you use debian stable, you need to install go manually:
  ```sh
  wget https://golang.org/dl/go1.13.14.linux-amd64.tar.gz
  tar -C /usr/local -xzf go1.13.14.linux-amd64.tar.gz
  export PATH=$PATH:/usr/local/go/bin
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  ```
  [Goolong does not work with go 1.14](https://github.com/gleissen/goolong/issues/2), so the version 1.13 is needed.

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
The command should ouput the ID of the replica, a number between 0 and 8.

If you did an error, you can reset the state of the repo with `git checkout .` and then try again.

### Install PSync

This covers both ReSync and PSync.

1. Installing and build PSync:
   ```sh
   git clone https://github.com/dzufferey/psync.git
   cd psync
   sbt compile
   sbt test:compile
   ./utils/generateClassPath.sh
   export PSYNC=$PWD
   echo "export PSYNC=$PWD" >> ~/.bashrc
   ```
2. Local test run, part 1
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
   Warnings are harmless and serves as indication of places when the runtime can be improved (better resource managemenet, graceful shutdown, etc.).

   On recent version of java, you may see
   ```
   WARNING: An illegal reflective access operation has occurred
   WARNING: Illegal reflective access by com.esotericsoftware.kryo.util.UnsafeUtil (file:/home/zufferey/.cache/coursier/v1/https/repo1.maven.org/maven2/com/esotericsoftware/kryo-shaded/4.0.2/kryo-shaded-4.0.2.jar) to constructor java.nio.DirectByteBuffer(long,int,java.lang.Object)
   WARNING: Please consider reporting this to the maintainers of com.esotericsoftware.kryo.util.UnsafeUtil
   WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
   WARNING: All illegal access operations will be denied in a future release
   ```
   This can also be ignored.
   The library we use for serialization ([twitter chill](https://github.com/twitter/chill)) uses some deprecated features of the JVM.
2. Local test run, part 2
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
3. Distributed test run:
   ...

TODO give md5sum/hash of commits files

### Install LibPaxos3

To install LibPaxos3, we follow the instructions from https://bitbucket.org/sciascid/libpaxos/src/master/

1. building LibPaxos3
   ```sh
   git clone https://bitbucket.org/sciascid/libpaxos.git
   mkdir libpaxos/build
   cd libpaxos/build
   cmake ..
   make
   export LPAXOS=$PWD
   echo "export LPAXOS=$PWD" >> ~/.bashrc
   ```
2. local test run
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
3. distributed test run
   ```sh
   # from the libpaxos/build folder
   ...
   ```
   TODO ...

TODO give md5sum/hash of commits files

### Install etcd

1. We install etcd from source as the benchmarking tool for etcd does not come with the standard installation.
   The last verison of etcd to build with go 1.13 is etcd 3.4.9.
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
   This install the latest version of etcd (3.4.10 when writting this).
3. local test run
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
4. distributed test run
   TODO ...

### Install Goolong

To install and run Goolong, we follow the information from https://github.com/gleissen/goolong/ and https://goto.ucsd.edu/~rkici/popl19_artifact_evaluation/.

1. clone and build goolong
   ```sh
   git clone https://github.com/gleissen/goolong.git
   cd goolong
   ```
   Before, we can build goolong we need to [make a small fix](https://github.com/gleissen/goolong/issues/1).
   Open the file `src/multipaxos/multipaxos.go` and on line 495, replace `Assign` by `Put`.
   Now we can build goolong.
   ```sh
   make
   export GOOLONG=$PWD
   echo "export GOOLONG=$PWD" >> ~/.bashrc
   ```
2. local test run
   running
   ```sh
   # in the goolong folder
   ./run_paxos.sh
   ```
   should produce an ouput which looks like:
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
3. distributed test run.
   TODO ...


### Install Bft-SMaRt

To install Bft-SMaRt, we follow the instructions from https://github.com/bft-smart/library

1. Download and ant Bft-SMaRt
   ```sh
   wget https://github.com/bft-smart/library/archive/v1.2.tar.gz
   tar -xzf v1.2.tar.gz
   cd library-1.2
   ant
   export BFTS=$PWD
   echo "export BFTS=$PWD" >> ~/.bashrc
   ```
2. local test run
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
3. distributed test run
   TODO ...

## Step by Step Instructions

We now explain how to reproduce the following

1. Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)
2. Byzantine test: ReSync against Bft-SMaRt (Figure 8b)
3. Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)
4. Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)
5. Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)

TODO for each test
- how to run (configuration files, scripts)
- how to interpret the output (compute throughput, etc.)
- what parameters can be tweaked

### Benign test: ReSync against LibPaxos3, etcd, Goolong and PSync (Figure 8a)

#### ReSync

```
./test_scripts/testBLV.sh --conf $RESYNC/batching/3replicas-conf.xml -to 5 --cr 2700
./test_scripts/testBLV.sh --conf $RESYNC/batching/4replicas-conf.xml -to 5 --cr 2700
./test_scripts/testBLV.sh --conf $RESYNC/batching/5replicas-conf.xml -to 5 --cr 2700
./test_scripts/testBLV.sh --conf $RESYNC/batching/6replicas-conf.xml -to 5 --cr 2700
./test_scripts/testBLV.sh --conf $RESYNC/batching/7replicas-conf.xml -to 5 --cr 2700 (reduced cr or fewer forward)
./test_scripts/testBLV.sh --conf $RESYNC/batching/8replicas-conf.xml -to 5 --cr 2700 (reduced cr or fewer forward)
./test_scripts/testBLV.sh --conf $RESYNC/batching/9replicas-conf.xml -to 5 --cr 2700 (reduced cr or fewer forward)
```

#### PSync

```
./test_scripts/testBLV.sh --conf 3replicas-conf.xml -to 2 --cr 1200  --syncTO
./test_scripts/testBLV.sh --conf 4replicas-conf.xml -to 3 --cr 800  --syncTO
./test_scripts/testBLV.sh --conf 5replicas-conf.xml -to 4 --cr 700  --syncTO
./test_scripts/testBLV.sh --conf 6replicas-conf.xml -to 3 --cr 600 --syncTO
./test_scripts/testBLV.sh --conf 7replicas-conf.xml -to 3 --cr 400 --syncTO
./test_scripts/testBLV.sh --conf 8replicas-conf.xml -to 4 --cr 300 --syncTO
./test_scripts/testBLV.sh --conf 9replicas-conf.xml -to 5 --cr 300 --syncTO
```


#### LibPaxos3

```
libpaxos 3 on mpi_9
-- for the server
cd dz_xp/libpaxos/build
./run_replicas.sh -n 9
-- for the client
cd dz_xp/libpaxos/build
./sample/client paxos9.conf -o 1000 -p 0 -v 8192
./sample/client paxos9.conf -o 100 -p 0 -v 32768
```

#### etcd

...

#### Goolong

```
-> run_server.sh -n N -b
-> run_client.sh -n N -q 10000000
```

### Byzantine test: ReSync against Bft-SMaRt (Figure 8b)

#### ReSync

```
./test_scripts/testTempByzantine.sh --conf b9replicas-conf.xml --noForwarding
rest of options in config
n = 9 -> 4.65 (406k)
n = 8 -> 5.75 (503k)
n = 7 -> 7.04 (610k) -to 1000
n = 6 -> 6.54 (571k) -to 300
n = 5 -> 7.74 (676k) -to 300
n = 4 -> 8.15 (712k) -to 200
```

#### Bft-SMaRt

```
n = 9, f = 2
./run_client.sh -t 7[8] -o10000 -s 1536
1536 × 2135 ÷ 1024 ÷ 1024 = 3.13
./run_client.sh -t 7 -o 10000 -s 2048
2048 × 1850 ÷ 1024 ÷ 1024 = 3.61
------

n = 8, f = 2
./run_client.sh -t 12 -o 10000 -s 1536
1536 × 3000 ÷ 1024 ÷ 1024 = 4.39
./run_client.sh -t 12 -o 10000 -s 2048
2048 × 2450 ÷ 1024 ÷ 1024 = 4.79

------

n = 7, f = 2
./run_client.sh -t 14 -o 20000 -s 2048
2048 × 3000 ÷ 1024 ÷ 1024 = 5.86
./run_client.sh -t 16 -o 8000 -s 4096
4096 × 2200 ÷ 1024 ÷ 1024 = 8.59
./run_client.sh -t 10 -o 8000 -s 8192
8192 × 1100 ÷ 1024 ÷ 1024 = 8.59

---

n = 6, f = 1
./run_client.sh -t 13 -o 8000 -s 8192
8192 × 1300 ÷ 1024 ÷ 1024 = 10.16

----

n = 5, f = 1
./run_client.sh -t 16 -o 8000 -s 8192
8192 × 1450 ÷ 1024 ÷ 1024 = 11.32
./run_client.sh -t 14 -o 8000 -s 16384
16384 ÷ 1024 ÷ 1024 × 760 = 11.86

----

n = 4, f = 1
./run_client.sh -t 16 -o 8000 -s 16384
16384 × 900 ÷ 1024 ÷ 1024 = 14.06
```


### Comparing progress conditions for the two-phase commit protocol with TCP and a 5ms timeout (Figure 9a)


### Comparing progress conditions in Paxos with TCP transport and a 5ms timeout (Figure 9b)


### Effect of timeout values and transport layer in Paxos with 9 replicas progressing on quorum (Figure 9c)

./test_scripts/testLV.sh -to 3 --protocol TCP -rt 20


## Caveats

Different Replicas may show different results ...
Timeouts ...
