% manually load .mat saved from PVBS containing recordings first (not analysis results)

% set columns (e.g. timestamp at column 1, V_m at column 2, i_cmd at column 3)
timeStampColumn = 1;
voltageColumn = 2;

% example data to display (set either to 0 to ignore)
displayExp = 1; % experiment # from the list of experiments
displaySwp = 1; % sweep # from the experiment selected above

% read data
vRec = h.exp.data.VRec;
%experimentCount = h.exp.experimentCount % this will also work
experimentCount = size(vRec, 2);

% initialize output
vd = cell(1, experimentCount); % V, dV/dt
%  NB. the result will be 1 data point shorter than the original recording,
%      as it calculates dV; to force same length as input (for whatever
%      reason), set the following variable to 1 instead of 0
appendNan = 0; % can't think of when it can be actually useful, but meh

% do stuff
for i = 1:experimentCount
    vRecTemp = vRec{i};
    sweepCount = size(vRecTemp, 2);
    vdTemp = cell(1, sweepCount);
    for j = 1:sweepCount
        vRecTempTemp = vRecTemp{j};
        [v, dvdt] = getDvdt(vRecTempTemp, timeStampColumn, voltageColumn);
        vdTemp{j} = [v, dvdt];
    end
    vd{i} = vdTemp;
end

% plot just one example
if (displayExp*displaySwp)
    plotTarget = vd{displayExp};
    plotTarget = plotTarget{displaySwp};
    figure;
    plot(plotTarget(:,1), plotTarget(:,2));
    ylabel('dV/dt (mV/ms)'); % timestamp is in units of (ms) for .mat saved from PVBS
    xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS
end

% clean up
clear i j
clear experimentCount sweepCount
clear timeStampColumn voltageColumn
clear vRec vRecTemp vRecTempTemp
clear vdTemp v dvdt
clear displayExp displaySwp plotTarget
clear appendNan

% actually doing stuff here
function [v, dvdt] = getDvdt(inputArray, tColumn, vColumn)
% calculate dV/dt from an (n*m) array
% take time and voltage columns as arguments
% disregard other columns in the array

t = inputArray(:, tColumn);
v = inputArray(:, vColumn);
dvdt = v; % initializing

dvdt = diff(dvdt); % NB. first row is lost here from using diff()
dt = diff(t); % ditto

dvdt = dvdt ./ dt;
v = v(2:end); % to match with dvdt

end