function [Twaves] = SRS(s)
%SRS - segment T-waves when dealing with ECGI data
%   T-wave segmentation method tailored to ECGI data. For more information
%   look at http://dx.doi.org/10.22489/CinC.2023.018
% 
% INPUT:
%       s: ECG signals
%
% OUTPUT:
%       Twaves: T-waves segmented

pt = 338;
step = 10;
L_s = size(s,2);
taux = 1:step:L_s;
s_now = s(pt,taux);
rs = s_now > 9.7; %threshold
r_pos = find(rs == 1);
for r_wave_loc = 1:length(r_pos)-1
    if r_pos(r_wave_loc) == r_pos(r_wave_loc+1)-1
        if s_now(r_pos(r_wave_loc)) > s_now(r_pos(r_wave_loc+1))
            rs(r_pos(r_wave_loc+1)) = 0;
        else
            rs(r_pos(r_wave_loc)) = 0;
        end
    end
end
rs = find(rs == 1);

QRS1 = 0; 
QRS2 = 1;
while QRS1 ~= QRS2
    figure(20); clf
    samples = 1:length(s_now);
    plot(samples,s_now)
    hold on
    plot(samples(rs),s_now(rs),'ro')
    title('Zoom in, press any keyboard button, and segment one beat')
    zoom on;
    pause()
    zoom off;
    [x,~] = ginput(2);
    zoom out
    hold on
    xline(x, '-', {'t_1','t_2'}, LabelOrientation='horizontal')
    hold off

    index_QRS1 = find(rs>x(1));
    QRS1 = rs(index_QRS1(1));
    index_QRS2 = find(rs<x(2));
    QRS2 = rs(index_QRS2(end));
end

QRS = QRS1;
ta = floor(QRS-x(1));
tb = floor(x(2)-QRS);

beat_startpoints = zeros(1,length(rs));
beat_endpoints = zeros(1,length(rs));

rs = rs(2:end-1);

figure(24)
for N_pt=1:size(s,1)
    ini_refBeat = floor(x(1)); fin_refBeat = floor(x(2));
    indices = find(samples>=ini_refBeat & samples<=fin_refBeat);
    plot(samples(indices),s(N_pt,taux(indices)))
    hold on
end
title('Select the points where T-Waves start and end')
[xTWave,~] = ginput(2);
xline(xTWave, '-', {'t_{on}','t_{off}'}, LabelOrientation='horizontal')
xline(x, '-', {'t_1','t_2'}, LabelOrientation='horizontal', LabelHorizontalAlignment='left')
hold off

tpon = floor(xTWave(1)-QRS);
tpoff = floor(xTWave(2)-QRS);
twave_startpoints = zeros(1,length(rs));
twave_endpoints = zeros(1,length(rs));
Twaves = {};

for N_rwaves=1:length(rs)
    twave_startpoints(N_rwaves) = taux(rs(N_rwaves)+tpon);  
    twave_endpoints(N_rwaves) = taux(rs(N_rwaves)+tpoff);   
    for j = 1:size(s,1)
        Twaves{j}(N_rwaves,:).wave = s(j,twave_startpoints(N_rwaves):twave_endpoints(N_rwaves));
        Twaves{j}(N_rwaves,:).lengthwin = length(Twaves{j}(N_rwaves,:).wave);
        Twaves{j}(N_rwaves,:).ind = [twave_startpoints(N_rwaves), twave_endpoints(N_rwaves)];
    end
end
