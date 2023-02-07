% <!> manually load .mat saved from PVBS containing recordings first 
%    (not analysis results .mat)


% ---------- set parameters here ----------

% assign columns (e.g. time at column 1, V_m at column 2 - PVBS default)
timeStampColumn = 1;
voltageColumn = 2;

% define AP threshold
%  variable apThresholdDvdt: 
%   AP threshold will be defined as Vm at which dV/dt first crosses this
%   value; _USE CAUTION_ not to detect the point of DC injection onset.
%   apThresholdDvdt = 10 will work if carefully done, 20 will return 
%   similar results (especially with oneStepAhead = 1) at lower sampling 
%   rates or with noisier recordings, while being safer
apThresholdDvdt = 20;
%  variable oneStepAhead (you think of a better name):
%   set to 1 (default) to take the Vm value immediately before crossing the 
%   above threshold dV/dt as the AP threshold, or set to 0 to take the Vm
%   immediately after; the former can be more useful for recordings with 
%   usual sampling rates (10 kHz, 20 kHz, ...) instead of higher sampling
%   rates intended for AP waveform analysis (e.g. >= 50 kHz)
oneStepAhead = 1; 

% example data to display (set either to 0 to skip display)
displayExp = 1; % experiment # from the list of experiments
displaySwp = 1; % sweep # from the experiment selected above

% --------------------


% read data
vRec = h.exp.data.VRec;
%experimentCount = h.exp.experimentCount % this will also work
experimentCount = size(vRec, 2);

% initialize output
vDvdt = cell(1, experimentCount); % V, dV/dt
%  NB. the result will be 1 data point shorter than the original recording,
%      as it calculates dV; to force same length as input (for whatever
%      reason), set the following variable to 1 instead of 0
appendNan = 0; % can't think of when it can be actually useful, but meh
apThreshold = cell(1, experimentCount); % AP threshold (mV) for each sweep

% get dV/dt
for i = 1:experimentCount
    vRecTemp = vRec{i};
    sweepCount = size(vRecTemp, 2);
    vdTemp = cell(1, sweepCount);
    for j = 1:sweepCount
        vRecTempTemp = vRecTemp{j};
        [v, dvdt] = getDvdt(vRecTempTemp, timeStampColumn, voltageColumn);
        vdTemp{j} = [v, dvdt];
    end
    vDvdt{i} = vdTemp;
end

% also get AP threshold - in a stupid redundant way coded by a stupid redundant person
if oneStepAhead
    for i = 1:experimentCount
        vDvdtTemp = vDvdt{i};
        sweepCount = size(vDvdtTemp, 2);
        apThresholdTemp = cell(1, sweepCount);
        for j = 1:sweepCount
            vDvdtTempTemp = vDvdtTemp{j};
            dvdtTemp = vDvdtTempTemp(:, 2); % dVdt was saved in column 2 by getDvdt()
            try
                iAmHere = find(dvdtTemp >= apThresholdDvdt, 1);
                iAmHere = iAmHere - 1; % one step ahead
                apThresholdTemp{j} = vDvdtTempTemp(iAmHere, 1);
            catch ME
                apThresholdTemp{j} = NaN;
            end
        end
        apThreshold{i} = apThresholdTemp;
    end
else
    for i = 1:experimentCount
        vDvdtTemp = vDvdt{i};
        sweepCount = size(vDvdtTemp, 2);
        apThresholdTemp = cell(1, sweepCount);
        for j = 1:sweepCount
            vDvdtTempTemp = vDvdtTemp{j};
            dvdtTemp = vDvdtTempTemp(:, 2); % dVdt was saved in column 2 by getDvdt()
            try
                iAmHere = find(dvdtTemp >= apThresholdDvdt, 1);
                apThresholdTemp{j} = vDvdtTempTemp(iAmHere, 1);
            catch ME
                apThresholdTemp{j} = NaN;
            end
        end
        apThreshold{i} = apThresholdTemp;
    end
end

% plot just one example
if (displayExp*displaySwp)
    plotTarget = vDvdt{displayExp};
    plotTarget = plotTarget{displaySwp};
    figure;
    plot(plotTarget(:,1), plotTarget(:,2));
    ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
    xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS
end


% clean up
clear i j
clear experimentCount sweepCount
clear timeStampColumn voltageColumn
clear vRec vRecTemp vRecTempTemp
clear vDvdtTemp vDvdtTempTemp
clear vdTemp v dvdt dvdtTemp
clear apThresholdDvdt apThresholdTemp iAmHere
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