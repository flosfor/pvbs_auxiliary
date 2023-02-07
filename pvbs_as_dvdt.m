% calculate dV/dt and AP threshold
%
% <!> manually load .mat saved from PVBS containing recordings first 
%    (not analysis results .mat)


% ---------- set parameters here ----------

% assign columns (e.g. time at column 1, V_m at column 2 - PVBS default)
timeStampColumn = 1;
voltageColumn = 2;

% define AP threshold
%
%  apThresholdDvdt: 
%   AP threshold will be defined as Vm at which dV/dt first crosses this
%   value; _USE CAUTION_ not to detect the point of DC injection onset.
%   apThresholdDvdt = 10 will work most of the time, 20 will return 
%   similar results (especially with oneStepAhead = 1) while being safer 
%   at lower sampling rates or with noisier recordings, but with larger 
%   error if interpolate == 1
    apThresholdDvdt = 10;
%
%  interpolate:
%   interpolate Vm value from those immediately before and after the 
%   above defined threshold (1 to enable, 0 to disable)
    interpolate = 0; 
%
%  oneStepAhead:  (you think of a better name)
%   _if_ interpolate == 0, set oneStepAhead = 1 to take the Vm value 
%   immediately before crossing the threshold dV/dt defined above 
%   as the AP threshold, otherwise to take the Vm value immediately after; 
%   oneStepAhead == 1 can be more useful for recordings with conventional 
%   sampling rates (10 kHz, 20 kHz, ...) instead of higher sampling rates 
%   intended for AP waveform analysis (e.g. >= 50 kHz)
    oneStepAhead = 1; 

% save after running
saveResults = 1; % 1 to save automatically, 0 to disable

% obsolete
%{
% example data to display (set either to 0 to skip display)
displayExp = 1; % experiment # from the list of experiments
displaySwp = 2; % sweep # from the experiment selected above
%}

% --------------------


% read data
vRec = h.exp.data.VRec;
%experimentCount = h.exp.experimentCount % this will also work
experimentCount = size(vRec, 2);
fileName = h.exp.fileName; % just for record keeping
filePath = h.exp.filePath; % ditto

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
if interpolate
    for i = 1:experimentCount
        vDvdtTemp = vDvdt{i};
        sweepCount = size(vDvdtTemp, 2);
        apThresholdTemp = cell(1, sweepCount);
        for j = 1:sweepCount
            vDvdtTempTemp = vDvdtTemp{j};
            dvdtTemp = vDvdtTempTemp(:, 2); % dVdt was saved in column 2 by getDvdt()
            try
                iAmHere = find(dvdtTemp >= apThresholdDvdt, 1);
                apThresholdTempHigh = vDvdtTempTemp(iAmHere, 1);
                apThresholdTempLow = vDvdtTempTemp(iAmHere - 1, 1);
                apThresholdTempHighDvdt = vDvdtTempTemp(iAmHere, 2);
                apThresholdTempLowDvdt = vDvdtTempTemp(iAmHere - 1, 2);
                apThresholdTempGiusto = apThresholdTempLow + (apThresholdTempHigh - apThresholdTempLow) * ((apThresholdDvdt - apThresholdTempLowDvdt) / (apThresholdTempHighDvdt - apThresholdTempLowDvdt));
                apThresholdTemp{j} = apThresholdTempGiusto;
            catch ME
                apThresholdTemp{j} = NaN;
            end
        end
        apThreshold{i} = apThresholdTemp;
    end
elseif oneStepAhead
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
%{
if (displayExp*displaySwp)
    plotTarget = vDvdt{displayExp};
    plotTarget = plotTarget{displaySwp};
    figure;
    plot(plotTarget(:,1), plotTarget(:,2));
    ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
    xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS
end
%}

% browser - initialize
dvdtWin = figure('name', 'dV/dt', 'numbertitle', 'off');
ui.dvdtPlot = axes('parent', dvdtWin, 'units', 'normalized', 'position', [0.15, 0.15, 0.75, 0.6], 'xminortick', 'on', 'yminortick', 'on', 'box', 'on');
ui.expList = uicontrol('parent', dvdtWin, 'Style', 'popupmenu', 'string', h.exp.fileName, 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.25, 0.8, 0.4, 0.05], 'Callback', @selectFile, 'interruptible', 'off');
ui.swpList = uicontrol('parent', dvdtWin, 'Style', 'popupmenu', 'string', {''}, 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.825, 0.8, 0.075, 0.05], 'Callback', @selectSweep, 'interruptible', 'off');
ui.expText = uicontrol('parent', dvdtWin, 'Style', 'text', 'string', 'Experiment:', 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.1, 0.8, 0.125, 0.05]);
ui.swpText = uicontrol('parent', dvdtWin, 'Style', 'text', 'string', 'Sweep:', 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.7, 0.8, 0.1, 0.05]);
ui.infoBox = uicontrol('parent', dvdtWin, 'Style', 'text', 'backgroundcolor', 'w', 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', apThresholdDvdt), 'horizontalalignment', 'left', 'Units', 'normalized', 'Position', [0.2, 0.6, 0.3, 0.1]);
h2 = struct();
h2.ui = ui;
h2.vDvdt = vDvdt;
h2.apThresholdDvdt = apThresholdDvdt;
h2.apThreshold = apThreshold;
guidata(dvdtWin, h2);

% browser - continued
vRecTemp = vRec{1};
sweepCountNow = size(vRecTemp, 2); % sweepCount was used earlier
sweepList = {};
for i = 1:sweepCountNow
    sweepList{end + 1} = num2str(i);
end
set(h2.ui.swpList, 'string', sweepList);
set(h2.ui.swpList, 'value', 1);
plotTarget = vDvdt{1}; % default to 1st experiment
plotTarget = plotTarget{1}; % default to 1st sweep
axes(ui.dvdtPlot);
plot(plotTarget(:,1), plotTarget(:,2), 'color', 'k');
hold on;
try
    set(ui.infoBox, 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', apThresholdDvdt));
    yline(apThresholdDvdt, 'color', 'r');
    apThresholdNow = apThreshold;
    apThresholdNow = apThresholdNow{1}; % default to 1st file
    apThresholdNow = apThresholdNow{1}; % default to 1st sweep
    xline(apThresholdNow, 'color', 'r');
    set(ui.infoBox, 'string', sprintf('AP threshold: %.2f (mV) \n(dV/dt = %.2f (V/s))', apThresholdNow, apThresholdDvdt));
catch ME
end
hold off;
ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS

% clean up... later
%{
clearvars -except fileName filePath vDvdt apThreshold vRec
%}

% save stuff in a real stupid way
if saveResults
    saveName = 'dvdt';
    savePath = cd;
    todayYY = num2str(year(datetime));
    todayYY = todayYY(end-1:end);
    todayMM = sprintf('%02.0f', month(datetime));
    todayDD = sprintf('%02.0f', day(datetime));
    todayhh = sprintf('%02.0f', hour(datetime));
    todaymm = sprintf('%02.0f', minute(datetime));
    todayss = sprintf('%02.0f', second(datetime));
    timeStamp = [todayYY, todayMM, todayDD ,'_', todayhh, todaymm, todayss];
    saveName = [saveName, '_', todayYY, todayMM, todayDD, '_', todayhh, todaymm, todayss];
    saveName = [saveName, '.mat'];
    savePath = [savePath, '\']; % appending backslash for proper formatting
    cd(savePath);
    warning('off'); % in case directory exists for mkdir below - shouldn't be relevant for now
    mkdir(timeStamp);
    warning('on');
    savePath = [savePath, timeStamp, '\'];
    saveName = [savePath, saveName];
    clearvars -except fileName filePath vDvdt apThreshold vRec saveName
    save(saveName);
else
    clearvars -except fileName filePath vDvdt apThreshold vRec saveName
end


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

% doing extra stuff
function selectFile(src, ~)
h2 = guidata(src);
vDvdt = h2.vDvdt;
fileNum = src.Value;
vDvdtTemp = vDvdt{fileNum};
sweepCountNow = size(vDvdtTemp, 2); % sweepCount was used earlier
sweepList = {};
for i = 1:sweepCountNow
    sweepList{end + 1} = num2str(i);
end
set(h2.ui.swpList, 'string', sweepList);
set(h2.ui.swpList, 'value', 1);
vDvdtTemp = vDvdtTemp{1}; % default to 1st sweep
axes(h2.ui.dvdtPlot);
plot(vDvdtTemp(:,1), vDvdtTemp(:,2), 'color', 'k');
hold on;
try
    set(h2.ui.infoBox, 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', h2.apThresholdDvdt));
    yline(h2.apThresholdDvdt, 'color', 'r');
    apThresholdNow = h2.apThreshold;
    apThresholdNow = apThresholdNow{fileNum};
    apThresholdNow = apThresholdNow{1}; % default to 1st sweep
    xline(apThresholdNow, 'color', 'r');
    set(h2.ui.infoBox, 'string', sprintf('AP threshold: %.2f (mV) \n(dV/dt = %.2f (V/s))', apThresholdNow, h2.apThresholdDvdt));
catch ME
end
hold off;
ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS
guidata(src, h2);
end

% doing extra extra stuff
function selectSweep(src, ~)
h2 = guidata(src);
vDvdt = h2.vDvdt;
fileNum = h2.ui.expList.Value;
vDvdtTemp = vDvdt{fileNum};
sweepCountNow = src.Value;
vDvdtTemp = vDvdtTemp{sweepCountNow};
axes(h2.ui.dvdtPlot);
plot(vDvdtTemp(:,1), vDvdtTemp(:,2), 'color', 'k');
hold on;
try
    set(h2.ui.infoBox, 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', h2.apThresholdDvdt));
    yline(h2.apThresholdDvdt, 'color', 'r');
    apThresholdNow = h2.apThreshold;
    apThresholdNow = apThresholdNow{fileNum};
    apThresholdNow = apThresholdNow{sweepCountNow};
    xline(apThresholdNow, 'color', 'r');
    set(h2.ui.infoBox, 'string', sprintf('AP threshold: %.2f (mV) \n(dV/dt = %.2f (V/s))', apThresholdNow, h2.apThresholdDvdt));
catch ME
end
hold off;
ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS
guidata(src, h2);
end

