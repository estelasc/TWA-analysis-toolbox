% MAIN - main script showing the coding steps
clear all; close all
addpath(genpath('data'))
addpath(genpath('functions'))

load("data.mat")
nodes = episurf.nodes;
mesh = episurf.mesh;
fs = 2048;
L_b = 510;

% Add BW
A_n = 1.75e-1;
pots = add_BW(epipots,fs,A_n);

% Add high-frequency noise
A_n = 1.6e-1;
pots = add_high_freq_noise(pots,A_n);

% Detrend the signals
n_nodes = size(epipots,1);
pots = [pots(:,1:L_b) pots pots(:,end-L_b+1:end)];
cleanECGs = zeros(size(pots));
for i = 1:n_nodes
    cleanECGs(i,:) = spline_detrending_filter(pots(i,:),L_b,fs);
end
cleanECGs = cleanECGs(:,L_b+1:end-L_b);

% Filter high-frequency noise
for i = 1:n_nodes
    cleanECGs(i,:) = low_pass_filter(cleanECGs(i,:),fs);
end

% Segment T-waves using the SRS method
[TWaves] = SRS(cleanECGs);

% Add synthetic alternans
n_TWA = [-36.04, -1.11, 303.35];
A_TWA = 3e-2;
[protoOdd, protoEven, oddTwaves, evenTwaves] = add_TWA(TWaves,n_TWA,A_TWA,nodes);

% Apply the MnL-based TWA detection algorithm
MC_WindowSHAP = true;
tic
[TWAstate] = MnL_based_TWA_detection_algorithm(protoEven,protoOdd,mesh,nodes,MC_WindowSHAP);
toc

if TWAstate == 1
    disp("This subject exhibits TWA")
else
    disp("This subject does not exhibit TWA")
end

