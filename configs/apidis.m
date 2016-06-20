global CONFIG; CONFIG = [];
global CONST; CONST = [];
global DATASET; DATASET = [];
global KSP; KSP = [];
global OPTVARS; OPTVARS = [];

%% MAIN SETTINGS

% Define states of the ball and people
% States are identified by numbers 1 to 26
% And are associated with lowercase English letters
% Ex. 'p' for possession = #16 = 'p' - 'a' + 1

% First 3 states are REQUIRED
CONST.People      = 'o' - 'a' + 1;
CONST.NoBall      = 'n' - 'a' + 1;
CONST.Possession  = 'p' - 'a' + 1;

% Another user-defined states here
CONST.Flying      = 'f' - 'a' + 1;
CONST.Pass        = 'h' - 'a' + 1;
CONST.Ground      = 'g' - 'a' + 1;

% List states that are going to be used
% These are the states that should be present in the training data

% There is no rolling ball in the training data of APIDIS
% so CONST.Ground is not used
CONST.StatesForClassifier = [CONST.Possession, CONST.Flying, CONST.Pass];

% Prior for the transition prior
% For each pair of states there are 5 'imaginary' transitions between them
% In addition to those observed in the training data
CONST.TransitionPrior = 5;

% Physical modes for each of the states
% One of 'Possession', 'Parabolic', 'Linear'
CONST.Model = cell(26, 1);
CONST.Model{CONST.Possession} = 'Possession';
CONST.Model{CONST.Flying}     = 'Parabolic';
CONST.Model{CONST.Pass}       = 'Parabolic';

% We differentiate between possession at different heights
% Sometimes that allows for more precise tracking
CONST.PossessionHeights = [500 1000 1500 2000 2500];

% Vicinity of the ball in which we count the number of players
% See 4.Image Evidence Potential section of the paper
% Also the vicinity of player in which we assume the ball can be
% possessed by the player.
CONST.PossessionVicinity = 2000;


% Used to detect when the ball is close to the
% floor and balistic trajectory should not be enforced
% Should be approximately radius of the ball
CONST.GroundLevel = 250;

% Define dataset information

% Path to the directory with images. Only needed if you want visualization
root = '/Volumes/cvlabdata1/cvlab/datasets_andrii/APIDIS/';
DATASET.Source_fmt = [root, 'source/source_c%d_f%d.png'];

% Frame idxes
CONFIG.Frames = 1:150;

% Defaulta camera view
DATASET.DefaultCam = 6;

% Path to the XML with calibrations
DATASET.Cam = Read_Camera_Calibration_From_Xml(...
        {['cali/calibration_cam0.xml'],...
         ['cali/calibration_cam1.xml'],...
         ['cali/calibration_cam2.xml'],...
         ['cali/calibration_cam3.xml'],...
         ['cali/calibration_cam4.xml'],...
         ['cali/calibration_cam5.xml'],...
         ['cali/calibration_cam6.xml']});

% Size of the tracking area, mm
DATASET.Court.X = 28000;
DATASET.Court.Y = 15000;
DATASET.Court.Z = 08000;

% Offset between (0, 0) in world coordinates and the corner of the field
DATASET.Offset.X = 1600;
DATASET.Offset.Y = 2600;

% Number of points on each axis to discretize for tracking
% You want the grid to be dense enough such that
% between two frames a person / a ball can travel at most
% from one point to the next / previous one along each axis
DATASET.Grid.X = 128;
DATASET.Grid.Y = 72;
DATASET.Grid.Z = 16;

% Assuming default 60 fps
DATASET.Fps = 60 / (CONFIG.Frames(2) - CONFIG.Frames(1));

% Locations in which physical model should be turned off (excluding floor)
% Format: N x 6, [x0 y0 z0 x1 y1 z1;]
DATASET.baskets = zeros(0, 6);

% Maximum allowed error between the detection and true location of the
% tracked ball, D_l in the paper
OPTVARS.ContinuousDiscreteDelta = 250;
% Large constant used to linearize the product, K in Eq. 5 of the paper
% Should be >> speed, acceleration, location values
OPTVARS.LargeM = 1e6;

% Path to ground truth file (for evaluation of results / training the classifier)
CONFIG.GtBall      = 'data/apidis_ball_gt/apidis.gt';
CONFIG.DetBall     = 'data/apidis_ball_det/apidis.det';
CONFIG.DetPeople   = 'data/apidis_pom/%d.pom';

% Path to the trained classifier model / priors
CONFIG.TrainedModel = 'models/apidis_priors.mat';
% Path to the data on which to train the classifier
CONFIG.TrainingGT = 'data/apidis_ball_gt/apidis.gt';

% Output file
CONFIG.Output = 'data/apidis_output.txt';



















%% UNDER THE HOOD SETTINGS

% Additional states that are required to be present
CONST.Source      = 30;
CONST.Sink        = 31;

% Size of the bounding volume for the human
DATASET.Human.X  = 0400;
DATASET.Human.Y  = 0400;
DATASET.Human.Z  = 1850;

% Discretization of the world locations for tracking (both for ball and players)
% Assumed to be uniformly distributed on the axes
DATASET.Loc.X    = ((1:DATASET.Grid.X) - 1) * DATASET.Court.X / (DATASET.Grid.X - 1);
DATASET.Loc.Y    = ((1:DATASET.Grid.Y) - 1) * DATASET.Court.Y / (DATASET.Grid.Y - 1);
DATASET.Loc.Z    = ((1:DATASET.Grid.Z) - 1) * DATASET.Court.Z / (DATASET.Grid.Z - 1);

% Parameters of people tracker / ball tracker

KSP.Binary = 'code/KSP/ksp';

% Maximum distance traveled along x / y (in discrete points)
KSP.People.Depth        = 1;
% Maximum distance traveled along z axis (obviously, 0 for people)
KSP.People.DepthOrt     = 0;
% Size of batch
KSP.People.BatchSize    = 100;
% Penalizes very short tracklets (by default single perfect detection
% has a cost of log(0.999/0.001) ~ 7, which means trajectories of length
% less than 3 will be ignored by the tracker).
KSP.People.MinPathCost  = 20;
% To obtain people tracklets, or to use people trajectories as is?
% = 0 : Operate on the graph of trajectories
% = 1 : Create graph of tracklets, join tracklets, operate on it
KSP.People.UseTracklets = 0;

KSP.Ball.Depth          = 1;
KSP.Ball.AllAccessPts   = 1;
KSP.Ball.MinPathCost    = 0;
KSP.Ball.BatchSize      = 100;
% To obtain ball tracklets, one can use KSP, or a simpler heuristics based
% on linking adjacent detections. They seem to give similar performance
% but the latter is faster and doesn't require discretizing the detection
% locations, which is why it is preferred.
KSP.Ball.UseKSP         = 0;


% Pruning data
% We can tolerate at most this many frames to join people tracklets
KSP.People.MaxJoinLimit = 20;
KSP.Ball.MaxJoinLimit = 45;


% Thresholding the detections before taking the log
CONST.MIN_OCCUR = 0.0001;
CONST.MAX_OCCUR = 0.9999;

% Limits for size of the graph / number of vars in the optimization
OPTVARS.MAX_COEFS  = 100000000;
OPTVARS.MAX_CONSTR = 10000000;
OPTVARS.MAX_VARS   = 10000000;

OPTVARS.MAX_GRAPH  = 5000000;
