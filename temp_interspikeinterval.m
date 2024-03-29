% manually load results .mat (exported from PVBS) including field "spike_times"

%{
%spike_times = {};
isi = {};
isi_rheobase = {};
isi_rheobase_x2 = {};
%}
expCount = length(h.intrinsicProperties);
for i = 1:expCount %%% NOT working properly yet
    output = isiAnalysis(i, h);
    %{
    isi{end + 1} = output.isi;
    isi_rheobase{end + 1} = output.isi_rheobase;
    isi_rheobase_x2{end + 1} = output.isi_rheobase_x2;
    %}
    try
        h.intrinsicProperties{i}.isi = output.isi;
    catch ME
        h.intrinsicProperties{i}.isi = nan;
    end
    try
        h.intrinsicProperties{i}.isi_rheobase = output.isi_rheobase;
        h.intrinsicProperties{i}.isi_rheobase_x2 = output.isi_rheobase_x2;
    catch ME
        h.intrinsicProperties{i}.isi_rheobase = nan;
        h.intrinsicProperties{i}.isi_rheobase_x2 = nan;
    end
end

clearvars -except h isi isi_rheobase isi_rheobase_x2 tumor epil


function output = isiAnalysis(idx, h)

output = struct;

currentExp = h.intrinsicProperties{idx};
isi = currentExp.spike_times; % initializing
for i = 1:length(isi)
    isiCurrentSweep = isi{i};
    isiCurrentSweep = diff(isiCurrentSweep);
    isi{i} = isiCurrentSweep;
end
output.isi = isi;

isi_rheobase = []; % ditto
isi_rheobase_x2 = []; % ditto
try
    rheobaseSweep = currentExp.rheobase_sweep;
    isi_rheobase= isi{rheobaseSweep};
    output.isi_rheobase = isi_rheobase;
    rheobaseX2Sweep = currentExp.rheobase_x2_sweep;
    isi_rheobase_x2= isi{rheobaseX2Sweep};
    output.isi_rheobase_x2 = isi_rheobase_x2;
catch ME
end

end
