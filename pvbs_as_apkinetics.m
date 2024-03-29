% calculate dV/dt and AP threshold
%
% <!> manually load .mat saved from PVBS containing recordings first 
%    (not analysis results .mat)


% ---------- set parameters here ----------

% save after running
    saveResults = 1; % 1 to save automatically, 0 to disable

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
    apThresholdDvdt = 10; % (V/s)
%
%  apDetectionThreshold:
%   self-explanatory, but 1) not to be confused with AP threshold
    apDetectionThreshold = 0; % (mV); this will be used for peak detection
    apDetectionRearm = -10; % (mV); re-arm peak detection
    %apWidthMax = 2.5; % (ms); arbitrary, could be used instead of arm-rearm
%
%  rmpWindow:
%   window (t) to calculate RMP
    rmpWindow = 100; % (ms)
%
%  interpolate:
%   interpolate Vm value from those immediately before and after the 
%   above defined threshold (1 to enable, 0 to disable)
    interpolate = 0; % (Boolean)
%
%  oneStepAhead:  (you think of a better name)
%   _if_ interpolate == 0, set oneStepAhead = 1 to take the Vm value 
%   immediately before crossing the threshold dV/dt defined above 
%   as the AP threshold, otherwise to take the Vm value immediately after; 
%   oneStepAhead == 1 can be more useful for recordings with conventional 
%   sampling rates (10 kHz, 20 kHz, ...) instead of higher sampling rates 
%   intended for AP waveform analysis (e.g. >= 50 kHz)
    oneStepAhead = 1; % (Boolean)

% remove artifact (e.g. from bridge balancing)
    artifactStart = 100; % (ms)
    artifactDuration = 2; % (ms)

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
rmp = cell(1, experimentCount);
apThreshold = cell(1, experimentCount); % AP threshold (mV) for each sweep
apAmplitude = cell(1, experimentCount);
apTimeOfPeak = cell(1, experimentCount);
apHalfWidth = cell(1, experimentCount);
maxDepol = cell(1, experimentCount);
maxRepol = cell(1, experimentCount);

rmpAvg = [];
apThresholdAvg = [];
apAmplitudeAvg = [];
apTimeOfPeakAvg = [];
apHalfWidthAvg = [];
maxDepolAvg = [];
maxRepolAvg = [];

for i = 1:experimentCount

    % initialize
    vRecTemp = vRec{i};
    sweepCount = size(vRecTemp, 2);
    vdTemp = cell(1, sweepCount);
    rmpTemp = cell(1, sweepCount);
    apThresholdTemp = cell(1, sweepCount);
    apAmplitudeTemp = cell(1, sweepCount);
    apTimeOfPeakTemp = cell(1, sweepCount);
    apHalfWidthTemp = cell(1, sweepCount);
    maxDepolTemp = cell(1, sweepCount);
    maxRepolTemp = cell(1, sweepCount);
    
    for j = 1:sweepCount
        
        % initialize
        vRecTempTemp = vRecTemp{j};
        si = vRecTempTemp(2, timeStampColumn) - vRecTempTemp(1, timeStampColumn); % (ms); this will do
        rmpWindowPoints = rmpWindow/si; % converting ms to points
        artifactStartPoints = artifactStart/si; % ditto
        artifactDurationPoints = artifactDuration/si; % ditto

        % remove artifact
        vRecTempTemp(artifactStartPoints:artifactStartPoints + artifactDurationPoints, :) = nan;

        % get dV/dt and RMP
        [v, dvdt] = getDvdt(vRecTempTemp, timeStampColumn, voltageColumn);
        vDvdtTemp = [v, dvdt];
        vdTemp{j} = vDvdtTemp;
        rmpTempTemp = nanmean(vRecTempTemp(1:rmpWindowPoints, voltageColumn));
        rmpTemp{j} = rmpTempTemp;
        
        % get AP threshold
        vDvdtTempTemp = vDvdtTemp;
        dvdtTemp = vDvdtTempTemp(:, 2); % dVdt was saved in column 2 by getDvdt()
        if interpolate
            try
                apThresholdTime = find(dvdtTemp >= apThresholdDvdt, 1);
                apThresholdTempHigh = vDvdtTempTemp(apThresholdTime, 1);
                apThresholdTempLow = vDvdtTempTemp(apThresholdTime - 1, 1);
                apThresholdTempHighDvdt = vDvdtTempTemp(apThresholdTime, 2);
                apThresholdTempLowDvdt = vDvdtTempTemp(apThresholdTime - 1, 2);
                apThresholdTempGiusto = apThresholdTempLow + (apThresholdTempHigh - apThresholdTempLow) * ((apThresholdDvdt - apThresholdTempLowDvdt) / (apThresholdTempHighDvdt - apThresholdTempLowDvdt));
                apThresholdTemp{j} = apThresholdTempGiusto;
                apThresholdTempTemp = apThresholdTempGiusto;
            catch ME
                apThresholdTemp{j} = NaN;
                apThresholdTempTemp = NaN;
            end
        elseif oneStepAhead
            try
                apThresholdTime = find(dvdtTemp >= apThresholdDvdt, 1);
                apThresholdTime = apThresholdTime - 1; % one step ahead
                apThresholdTemp{j} = vDvdtTempTemp(apThresholdTime, 1);
                apThresholdTempTemp = vDvdtTempTemp(apThresholdTime, 1);
            catch ME
                apThresholdTemp{j} = NaN;
                apThresholdTempTemp = NaN;
            end
        else
            try
                apThresholdTime = find(dvdtTemp >= apThresholdDvdt, 1);
                apThresholdTemp{j} = vDvdtTempTemp(apThresholdTime, 1);
                apThresholdTempTemp = vDvdtTempTemp(apThresholdTime, 1);
            catch ME
                apThresholdTemp{j} = NaN;
                apThresholdTempTemp = NaN;
            end
        end

        try
            % get AP peak and time of peak
            vRecTempTempTemp = vRecTempTemp(:, voltageColumn);
            apPeakDetectionStart = find(vRecTempTempTemp >= apDetectionThreshold, 1);
            apPeakDetectionEnd = find(vRecTempTempTemp(apPeakDetectionStart:end) <= apDetectionRearm, 1);
            apPeakDetectionEnd = apPeakDetectionStart + apPeakDetectionEnd; % because the search started after position apPeakDetectionStart
            apPeakTempTemp = max(vRecTempTempTemp(apPeakDetectionStart:apPeakDetectionEnd));
            apAmplitudeTempTemp = apPeakTempTemp - apThresholdTempTemp;
            apAmplitudeTemp{j} = apAmplitudeTempTemp;
            apPeakTempIndex = find(vRecTempTempTemp(apPeakDetectionStart:apPeakDetectionEnd) == apPeakTempTemp);
            apPeakTempIndex = apPeakDetectionStart + apPeakTempIndex(1); % because the search started after position apPeakDetectionStart; just use the 1st entry in case there are duplicates
            apTimeOfPeakTemp{j} = vRecTempTemp(apPeakTempIndex, timeStampColumn);

            % get AP half-width
            apHalfPeakStart = find(vRecTempTempTemp(apThresholdTime:apPeakTempIndex) >= apThresholdTempTemp + 0.5*apAmplitudeTempTemp, 1); % just use the 1st entry in case there are duplicates
            apHalfPeakStart = apThresholdTime + apHalfPeakStart;
            apHalfPeakEnd = find(vRecTempTempTemp(apPeakTempIndex:end) <= apThresholdTempTemp + 0.5*apAmplitudeTempTemp, 1); % just use the last entry in case there are duplicates
            apHalfPeakEnd = apPeakTempIndex + apHalfPeakEnd;
            apHalfWidthTempTemp = apHalfPeakEnd - apHalfPeakStart; % later half not really necessary but just because of OCD
            apHalfWidthTemp{j} = apHalfWidthTempTemp*si; % converting from points to ms

            % get dVdt min/max
            maxDepolTempTemp = max(dvdt(apThresholdTime:apPeakTempIndex));
            maxRepolTempTemp = min(dvdt(apPeakTempIndex:apPeakTempIndex + 2*(apHalfPeakEnd-apPeakTempIndex))); % stupid, but will work without trouble
            maxDepolTemp{j} = maxDepolTempTemp;
            maxRepolTemp{j} = maxRepolTempTemp;

        catch ME
            apThreshold{j} = NaN; % to exclude artifacts
            apAmplitudeTemp{j} = NaN;
            apTimeOfPeakTemp{j} = NaN;
            apHalfWidthTemp{j} = NaN;
            maxDepolTemp{j} = NaN;
            maxRepolTemp{j} = NaN;
            continue
        end

    end
    
    vDvdt{i} = vdTemp;
    rmp{i} = rmpTemp;
    apThreshold{i} = apThresholdTemp;
    apAmplitude{i} = apAmplitudeTemp;
    apTimeOfPeak{i} = apTimeOfPeakTemp;
    apHalfWidth{i} = apHalfWidthTemp;
    maxDepol{i} = maxDepolTemp;
    maxRepol{i} = maxRepolTemp;

    rmpAvg(end + 1) = rmpTemp{1};
    apThresholdAvg(end + 1) = apThresholdTemp{1};
    apAmplitudeAvg(end + 1) = apAmplitudeTemp{1};
    apTimeOfPeakAvg(end + 1) = apTimeOfPeakTemp{1};
    apHalfWidthAvg(end + 1) = apHalfWidthTemp{1};
    maxDepolAvg(end + 1) = maxDepolTemp{1};
    maxRepolAvg(end + 1) = maxRepolTemp{1};

end

% organize output variables
rmpSEM = std(rmpAvg)/length(rmpAvg); % do them separately instead of, e.g. usining experimentCount, in case of any fuckup
apThresholdSEM = std(apThresholdAvg)/length(apThresholdAvg);
apAmplitudeSEM = std(apAmplitudeAvg)/length(apAmplitudeAvg);
apTimeOfPeakSEM = std(apTimeOfPeakAvg)/length(apTimeOfPeakAvg);
apHalfWidthSEM = std(apHalfWidthAvg)/length(apHalfWidthAvg);
maxDepolSEM = std(maxDepolAvg)/length(maxDepolAvg);
maxRepolSEM = std(maxRepolAvg)/length(maxRepolAvg);

rmpAvg = mean(rmpAvg);
apThresholdAvg = mean(apThresholdAvg);
apAmplitudeAvg = mean(apAmplitudeAvg);
apTimeOfPeakAvg = mean(apTimeOfPeakAvg);
apHalfWidthAvg = mean(apHalfWidthAvg);
maxDepolAvg = mean(maxDepolAvg);
maxRepolAvg = mean(maxRepolAvg);

% organize output struct
apKinetics = struct;
apKinetics.fileName = fileName;
apKinetics.filePath = filePath;
apKinetics.vRec = vRec;
apKinetics.vDvdt = vDvdt;
apKinetics.apThreshold = apThreshold;
apKinetics.apAmplitude = apAmplitude;
apKinetics.apTimeOfPeak = apTimeOfPeak;
apKinetics.apHalfWidth = apHalfWidth;
apKinetics.maxDepol = maxDepol;
apKinetics.maxRepol = maxRepol;
apKinetics.rmp = rmp;

analysisParams = struct;
analysisParams.timeStampColumn = timeStampColumn;
analysisParams.voltageColumn = voltageColumn;
analysisParams.apThresholdDvdt = apThresholdDvdt;
analysisParams.apDetectionThreshold = apDetectionThreshold;
analysisParams.apDetectionRearm = apDetectionRearm;
analysisParams.rmpWindow = rmpWindow;
analysisParams.interpolate = interpolate;
analysisParams.oneStepAhead = oneStepAhead;
apKinetics.analysisParams = analysisParams;

groupedAverage = struct; 
groupedAverage.rmpAvg = rmpAvg;
groupedAverage.apThresholdAvg = apThresholdAvg;
groupedAverage.apAmplitudeAvg = apAmplitudeAvg;
groupedAverage.apTimeOfPeakAvg = apTimeOfPeakAvg;
groupedAverage.apHalfWidthAvg = apHalfWidthAvg;
groupedAverage.maxDepolAvg = maxDepolAvg;
groupedAverage.maxRepolAvg = maxRepolAvg;
groupedAverage.rmpSEM = rmpSEM;
groupedAverage.apThresholdSEM = apThresholdSEM;
groupedAverage.apAmplitudeSEM = apAmplitudeSEM;
groupedAverage.apTimeOfPeakSEM = apTimeOfPeakSEM;
groupedAverage.apHalfWidthSEM = apHalfWidthSEM;
groupedAverage.maxDepolSEM = maxDepolSEM;
groupedAverage.maxRepolSEM = maxRepolSEM;
apKinetics.groupedAverage = groupedAverage;


% browser - initialize
dvdtWin = figure('name', 'AP kinetics', 'numbertitle', 'off', 'units', 'normalized', 'position', [0.25, 0.25, 0.27, 0.48]);
ui.dvdtPlot = axes('parent', dvdtWin, 'units', 'normalized', 'position', [0.15, 0.15, 0.75, 0.6], 'xminortick', 'on', 'yminortick', 'on', 'box', 'on');
expListStr = ['(All experiments)', h.exp.fileName];
ui.expList = uicontrol('parent', dvdtWin, 'Style', 'popupmenu', 'string', expListStr, 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.25, 0.855, 0.4, 0.05], 'Callback', @selectFile, 'interruptible', 'off');
ui.swpList = uicontrol('parent', dvdtWin, 'Style', 'popupmenu', 'string', {''}, 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.78, 0.855, 0.12, 0.05], 'Callback', @selectSweep, 'interruptible', 'off');
ui.expText = uicontrol('parent', dvdtWin, 'Style', 'text', 'string', 'Experiment:', 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.1, 0.85, 0.125, 0.05]);
ui.swpText = uicontrol('parent', dvdtWin, 'Style', 'text', 'string', 'Sweep:', 'horizontalalignment', 'right', 'Units', 'normalized', 'Position', [0.68, 0.85, 0.08, 0.05]);
%ui.infoBox = uicontrol('parent', dvdtWin, 'Style', 'text', 'backgroundcolor', 'w', 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', apThresholdDvdt), 'horizontalalignment', 'left', 'Units', 'normalized', 'Position', [0.2, 0.6, 0.25, 0.1]);
ui.infoBox = uicontrol('parent', dvdtWin, 'Style', 'text', 'backgroundcolor', 'w', 'string', sprintf('AP threshold: N/A \n(dV/dt = %.2f (V/s))', apThresholdDvdt), 'horizontalalignment', 'left', 'Units', 'normalized', 'Position', [0.175, 0.475, 0.25, 0.25]);
h2 = struct(); % fucking redundant because i wrote it in a stupid way and am not fixing it at this point
h2.ui = ui;
h2.vDvdt = vDvdt;
h2.apThresholdDvdt = apThresholdDvdt;
h2.apThreshold = apThreshold;
h2.apAmplitude = apAmplitude;
h2.apTimeOfPeak = apTimeOfPeak;
h2.apHalfWidth = apHalfWidth;
h2.maxDepol = maxDepol;
h2.maxRepol = maxRepol;
h2.rmp = rmp;
h2.groupedAverage = groupedAverage;
guidata(dvdtWin, h2);

% browser - continued
vRecTemp = vRec{1};
sweepCountNow = size(vRecTemp, 2); % sweepCount was used earlier
sweepList = {};
for i = 1:sweepCountNow
    sweepList{end + 1} = num2str(i);
end

%{
set(h2.ui.swpList, 'string', sweepList);
set(h2.ui.swpList, 'value', 1);
plotTarget = vDvdt{1}; % default to 1st experiment
plotTarget = plotTarget{1}; % default to 1st sweep
axes(ui.dvdtPlot);
plot(plotTarget(:,1), plotTarget(:,2), 'color', 'k');
hold on;
try
    set(ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', apThresholdDvdt));
    yline(apThresholdDvdt, 'color', 'r');
    apThresholdNow = apThreshold;
    apThresholdNow = apThresholdNow{1}; % default to 1st file
    apThresholdNow = apThresholdNow{1}; % default to 1st sweep
    apAmplitudeNow = apAmplitude;
    apAmplitudeNow = apAmplitudeNow{1}; % default to 1st file
    apAmplitudeNow = apAmplitudeNow{1}; % default to 1st sweep
    apHalfWidthNow = apHalfWidth;
    apHalfWidthNow = apHalfWidthNow{1}; % default to 1st file
    apHalfWidthNow = apHalfWidthNow{1}; % default to 1st sweep
    maxDepolNow = maxDepol;
    maxDepolNow = maxDepolNow{1}; % default to 1st file
    maxDepolNow = maxDepolNow{1}; % default to 1st sweep
    maxRepolNow = maxRepol;
    maxRepolNow = maxRepolNow{1}; % default to 1st file
    maxRepolNow = maxRepolNow{1}; % default to 1st sweep
    xline(apThresholdNow, 'color', 'r');
    set(ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', apThresholdNow, apThresholdDvdt));
    set(ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s)', apThresholdNow, apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow));
catch ME
end
hold off;
%}

set(h2.ui.swpList, 'string', '(N/A)');
set(h2.ui.swpList, 'value', 1);
try
    set(h2.ui.infoBox, 'Position', [0.175, 0.475, 0.5, 0.25]);
    set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, h2.apThresholdDvdt));
    apThresholdNow = h2.groupedAverage.apThresholdAvg;
    apAmplitudeNow = h2.groupedAverage.apAmplitudeAvg;
    apHalfWidthNow = h2.groupedAverage.apHalfWidthAvg;
    maxDepolNow = h2.groupedAverage.maxDepolAvg;
    maxRepolNow = h2.groupedAverage.maxRepolAvg;
    rmpNow = h2.groupedAverage.rmpAvg;
    apThresholdSEMNow = h2.groupedAverage.apThresholdSEM;
    apAmplitudeSEMNow = h2.groupedAverage.apAmplitudeSEM;
    apHalfWidthSEMNow = h2.groupedAverage.apHalfWidthSEM;
    maxDepolSEMNow = h2.groupedAverage.maxDepolSEM;
    maxRepolSEMNow = h2.groupedAverage.maxRepolSEM;
    rmpSEMNow = h2.groupedAverage.rmpSEM;
    set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt));
    %set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s) \nRMP: %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow, rmpNow));
    set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f %s %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f %s %.2f (mV) \nHalf-width: %.2f %s %.2f (ms) \nMax depol: %.2f %s %.2f (V/s) \nMax repol: %.2f %s %.2f (-V/s) \nRMP: %.2f %s %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, char(177), apThresholdSEMNow, h2.apThresholdDvdt, apAmplitudeNow, char(177), apAmplitudeSEMNow, apHalfWidthNow, char(177), apHalfWidthSEMNow, maxDepolNow, char(177), maxDepolSEMNow, -maxRepolNow, char(177), maxRepolSEMNow, rmpNow, char(177), rmpSEMNow));
catch ME
end

ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS

set(ui.dvdtPlot, 'xlim', [-100, 60]);
set(ui.dvdtPlot, 'ylim', [-250, 500]);

% clean up... later
%{
clearvars -except fileName filePath vDvdt apThreshold vRec
%}

% save stuff in a real stupid way
if saveResults
    saveName = 'apKinetics';
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
    %clearvars -except fileName filePath vDvdt apThreshold apPeak apHalfWidth maxDepol maxRepol rmp vRec saveName
    clearvars -except apKinetics saveName
    save(saveName);
else
    %clearvars -except fileName filePath vDvdt apThreshold apPeak apHalfWidth maxDepol maxRepol rmp vRec saveName
    clearvars -except apKinetics
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

%{
si = dt(1);
rmp = cazzo;
%}

v = v(2:end); % to match with dvdt

end

% doing extra stuff
function selectFile(src, ~)
h2 = guidata(src);
vDvdt = h2.vDvdt;
fileNum = src.Value;

if fileNum == 1
    fileNum = fileNum - 1;
    axes(h2.ui.dvdtPlot);
    cla;
    set(h2.ui.swpList, 'string', '(N/A)');
    set(h2.ui.swpList, 'value', 1);
    try
        set(h2.ui.infoBox, 'Position', [0.175, 0.475, 0.5, 0.25]);
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, h2.apThresholdDvdt));
        apThresholdNow = h2.groupedAverage.apThresholdAvg;
        apAmplitudeNow = h2.groupedAverage.apAmplitudeAvg;
        apHalfWidthNow = h2.groupedAverage.apHalfWidthAvg;
        maxDepolNow = h2.groupedAverage.maxDepolAvg;
        maxRepolNow = h2.groupedAverage.maxRepolAvg;
        rmpNow = h2.groupedAverage.rmpAvg;
        apThresholdSEMNow = h2.groupedAverage.apThresholdSEM;
        apAmplitudeSEMNow = h2.groupedAverage.apAmplitudeSEM;
        apHalfWidthSEMNow = h2.groupedAverage.apHalfWidthSEM;
        maxDepolSEMNow = h2.groupedAverage.maxDepolSEM;
        maxRepolSEMNow = h2.groupedAverage.maxRepolSEM;
        rmpSEMNow = h2.groupedAverage.rmpSEM;
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt));
        %set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s) \nRMP: %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow, rmpNow));
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f %s %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f %s %.2f (mV) \nHalf-width: %.2f %s %.2f (ms) \nMax depol: %.2f %s %.2f (V/s) \nMax repol: %.2f %s %.2f (-V/s) \nRMP: %.2f %s %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, char(177), apThresholdSEMNow, h2.apThresholdDvdt, apAmplitudeNow, char(177), apAmplitudeSEMNow, apHalfWidthNow, char(177), apHalfWidthSEMNow, maxDepolNow, char(177), maxDepolSEMNow, -maxRepolNow, char(177), maxRepolSEMNow, rmpNow, char(177), rmpSEMNow));
    catch ME
    end
else
    fileNum = fileNum - 1;
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
        set(h2.ui.infoBox, 'Position', [0.175, 0.475, 0.25, 0.25]);
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', h2.apThresholdDvdt));
        yline(h2.apThresholdDvdt, 'color', 'r');
        apThresholdNow = h2.apThreshold;
        apThresholdNow = apThresholdNow{fileNum};
        apThresholdNow = apThresholdNow{1};
        apAmplitudeNow = h2.apAmplitude;
        apAmplitudeNow = apAmplitudeNow{fileNum};
        apAmplitudeNow = apAmplitudeNow{1};
        apHalfWidthNow = h2.apHalfWidth;
        apHalfWidthNow = apHalfWidthNow{fileNum};
        apHalfWidthNow = apHalfWidthNow{1};
        maxDepolNow = h2.maxDepol;
        maxDepolNow = maxDepolNow{fileNum};
        maxDepolNow = maxDepolNow{1};
        maxRepolNow = h2.maxRepol;
        maxRepolNow = maxRepolNow{fileNum};
        maxRepolNow = maxRepolNow{1};
        rmpNow = h2.rmp;
        rmpNow = rmpNow{fileNum};
        rmpNow = rmpNow{1};
        xline(apThresholdNow, 'color', 'r');
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', apThresholdNow, h2.apThresholdDvdt));
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s) \nRMP: %.2f (mV)', apThresholdNow, h2.apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow, rmpNow));
    catch ME
    end
    hold off;
end

ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS

set(h2.ui.dvdtPlot, 'xlim', [-100, 60]);
set(h2.ui.dvdtPlot, 'ylim', [-250, 500]);

guidata(src, h2);
end

% doing extra extra stuff - stupid super redundant again in this patched-together code
function selectSweep(src, ~)
h2 = guidata(src);
vDvdt = h2.vDvdt;
fileNum = h2.ui.expList.Value;

if fileNum == 1
    fileNum = fileNum - 1;
    axes(h2.ui.dvdtPlot);
    cla;
    set(h2.ui.swpList, 'string', '(N/A)');
    set(h2.ui.swpList, 'value', 1);
    try
        set(h2.ui.infoBox, 'Position', [0.175, 0.475, 0.5, 0.25]);
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, h2.apThresholdDvdt));
        apThresholdNow = h2.groupedAverage.apThresholdAvg;
        apAmplitudeNow = h2.groupedAverage.apAmplitudeAvg;
        apHalfWidthNow = h2.groupedAverage.apHalfWidthAvg;
        maxDepolNow = h2.groupedAverage.maxDepolAvg;
        maxRepolNow = h2.groupedAverage.maxRepolAvg;
        rmpNow = h2.groupedAverage.rmpAvg;
        apThresholdSEMNow = h2.groupedAverage.apThresholdSEM;
        apAmplitudeSEMNow = h2.groupedAverage.apAmplitudeSEM;
        apHalfWidthSEMNow = h2.groupedAverage.apHalfWidthSEM;
        maxDepolSEMNow = h2.groupedAverage.maxDepolSEM;
        maxRepolSEMNow = h2.groupedAverage.maxRepolSEM;
        rmpSEMNow = h2.groupedAverage.rmpSEM;
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt));
        %set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s) \nRMP: %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, h2.apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow, rmpNow));
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics (n = %.0f) \n\nThreshold: %.2f %s %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f %s %.2f (mV) \nHalf-width: %.2f %s %.2f (ms) \nMax depol: %.2f %s %.2f (V/s) \nMax repol: %.2f %s %.2f (-V/s) \nRMP: %.2f %s %.2f (mV)', length(h2.ui.expList.String) - 1, apThresholdNow, char(177), apThresholdSEMNow, h2.apThresholdDvdt, apAmplitudeNow, char(177), apAmplitudeSEMNow, apHalfWidthNow, char(177), apHalfWidthSEMNow, maxDepolNow, char(177), maxDepolSEMNow, -maxRepolNow, char(177), maxRepolSEMNow, rmpNow, char(177), rmpSEMNow));
    catch ME
    end
else
    fileNum = fileNum - 1;
    vDvdtTemp = vDvdt{fileNum};
    sweepCountNow = src.Value;
    vDvdtTemp = vDvdtTemp{sweepCountNow};
    axes(h2.ui.dvdtPlot);
    plot(vDvdtTemp(:,1), vDvdtTemp(:,2), 'color', 'k');
    hold on;
    try
        set(h2.ui.infoBox, 'Position', [0.175, 0.475, 0.25, 0.25]);
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: N/A \n  (dV/dt = %.2f (V/s))', h2.apThresholdDvdt));
        yline(h2.apThresholdDvdt, 'color', 'r');
        apThresholdNow = h2.apThreshold;
        apThresholdNow = apThresholdNow{fileNum};
        apThresholdNow = apThresholdNow{sweepCountNow};
        apAmplitudeNow = h2.apAmplitude;
        apAmplitudeNow = apAmplitudeNow{fileNum};
        apAmplitudeNow = apAmplitudeNow{sweepCountNow};
        apHalfWidthNow = h2.apHalfWidth;
        apHalfWidthNow = apHalfWidthNow{fileNum};
        apHalfWidthNow = apHalfWidthNow{sweepCountNow};
        maxDepolNow = h2.maxDepol;
        maxDepolNow = maxDepolNow{fileNum};
        maxDepolNow = maxDepolNow{sweepCountNow};
        maxRepolNow = h2.maxRepol;
        maxRepolNow = maxRepolNow{fileNum};
        maxRepolNow = maxRepolNow{sweepCountNow};
        rmpNow = h2.rmp;
        rmpNow = rmpNow{fileNum};
        rmpNow = rmpNow{sweepCountNow};
        xline(apThresholdNow, 'color', 'r');
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s))', apThresholdNow, h2.apThresholdDvdt));
        set(h2.ui.infoBox, 'string', sprintf('AP kinetics \n\nThreshold: %.2f (mV) \n  (dV/dt = %.2f (V/s)) \nAmplitude: %.2f (mV) \nHalf-width: %.2f (ms) \nMax depol: %.2f (V/s) \nMax repol: %.2f (-V/s) \nRMP: %.2f (mV)', apThresholdNow, h2.apThresholdDvdt, apAmplitudeNow, apHalfWidthNow, maxDepolNow, -maxRepolNow, rmpNow));
    catch ME
    end
    hold off;
end

ylabel('dV/dt (V/s)'); % timestamp is in units of (ms) for .mat saved from PVBS
xlabel('V_m (mV)'); % voltage is in units of (mV) for .mat saved from PVBS

set(h2.ui.dvdtPlot, 'xlim', [-100, 60]);
set(h2.ui.dvdtPlot, 'ylim', [-250, 500]);

guidata(src, h2);
end

