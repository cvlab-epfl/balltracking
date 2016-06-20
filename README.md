# Description

This is a code for simultaneous tracking of the ball and the players in team sports.

For more details about the algorithm used,  please refer to and consider citing the following paper:

```
@article{maksai2015players,
  title={What Players do with the Ball: A Physically Constrained Interaction Modeling},
  author={Maksai, Andrii and Wang, Xinchao and Fua, Pascal},
  journal={arXiv preprint arXiv:1511.06181},
  year={2015}
}
```

Provided is the ground truth data from the publicly available [APIDIS](http://sites.uclouvain.be/ispgroup/index.php/Softwares/APIDIS) dataset, along with detections obtained by us. If you plan on using any part of this dataset, please refer to and consider citing the following paper:

```
@inproceedings{de2008distributed,
  title={Distributed video acquisition and annotation for sport-event summarization},
  author={De Vleeschouwer, Christophe and Chen, Fan and Delannay, Damien and Parisot, Christophe and Chaudy, Christophe and Martrou, Eric and Cavallaro, Andrea and others},
  booktitle={NEM summit 2008:: Towards Future Media Internet},
  year={2008}
}
```

# Building and Dependencies

For running the whole code, you need to be able to compile c++ code and run matlab files.

For the optimization, you should have [Gurobi](https://user.gurobi.com/download/gurobi-optimizer) installed.
Modify code/Actions/Compile_and_setup.m to write the path to the Gurobi distribution and license file on your system.

For running the K-shortest-paths optimization, you need [Boost](http://www.boost.org/) library installed.
Modify code/KSP/Makefile to write the path to the Boost library on your system.

Just run main.m file in matlab to run everything.

# Configuration

As system is designed to run with multiple sports, it has many configurations.
An example of configuration file for the APIDIS dataset is given in the configs/apidis.m
folder. It contains a reasonable setup for basketball. We plan to add another example for soccer in the future.

If you want to use your own configuration file, modify the name of the configuration file used at the top of the main.m.

The config file contains the necessary explanations. Top of the file contains settings that are expected to be changed more often.

# Data format

People detections file have the format of Probability Occupancy Map ([POM](http://cvlab.epfl.ch/software/pom)). For each frame T, for each discretized (X, Y) location on the ground, file T.pom contains a line:
Y * GX + X  0 Y * GX + X  P

First number is the encoding of the location on the ground plane.
Second number is the height.
Third number is the encoding of the location in 3D, and for people coinsides with the first one.
Fourth number is the output of the detector, ranging between 0 and 1.

Ball detections and ball ground truth have the following format:
First line of the file contains the number of the detections across all frames.
Each of the following lines is formatted as follows:
Frame number  X Y Z P S

P is the detector output, and is expected to be 1 for the ground truth.
S is the state of the ball (see configs/apidis.m for explanation on how states are encoded). For the detection file, S is expected to be 0.


# Troubleshooting

If the system uses too much memory, try decreasing the limit on the size of the graph and size of the optimization problem, both defined at the end of the config file.
