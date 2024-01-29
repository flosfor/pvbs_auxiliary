% manually load results .mat (exported from PVBS) including field intrinsicProperties


%clearvars -except group1_intrinsic group2_intrinsic


g1 = group1_intrinsic.intrinsicProperties;
g2 = group2_intrinsic.intrinsicProperties;


g1_isi = {};
g1_isi2 = {};
g1_length = [];
g1_length2 = [];
g1_fi = {};
g1_fi_length = [];
for i = 1:length(g1)
    g1_isi{end + 1} = g1{i}.isi_rheobase';
    g1_isi2{end + 1} = g1{i}.isi_rheobase_x2';
    g1_length(end + 1) = length(g1{i}.isi_rheobase);
    g1_length2(end + 1) = length(g1{i}.isi_rheobase_x2);
    g1_fi{end + 1} = g1{i}.f_i;
    g1_fi_length(end + 1) = length(g1{i}.f_i);
end
g1_length = max(g1_length);
g1_length2 = max(g1_length2);
g1_fi_length = max(g1_fi_length);

%%{
g1_isi_temp = nan(g1_length, length(g1));
g1_isi2_temp = nan(g1_length2, length(g1));
for i = 1:length(g1)
    if isempty(g1_isi{i})
        %continue
    else
        cazzo = nan(g1_length, 1);
        cazzo(1:length(g1_isi{i})) = g1_isi{i};
        g1_isi_temp(:, i) = cazzo;
    end
    if isempty(g1_isi2{i})
        %continue
    else
        cazzo = nan(g1_length2, 1);
        cazzo(1:length(g1_isi2{i})) = g1_isi2{i};
        g1_isi2_temp(:, i) = cazzo;
    end
end
g1_isi = g1_isi_temp;
g1_isi2 = g1_isi2_temp;

g1_isi2_n = g1_isi2;
for i = 1:size(g1_isi2, 2)
    g1_isi2_n(:, i) = g1_isi2_n(:, i)./g1_isi2(1, i);
end
%}

%%{
g1_fi_temp = nan(g1_fi_length, length(g1));
for i = 1:length(g1)
    if isempty(g1_fi{i})
        %continue
    else
        cazzo = nan(g1_fi_length, 1);
        merda = g1_fi{i};
        merda = merda(:,2); % column 1 is the i_cmd (pA), starting from 0 (hence aligned)
        cazzo(1:size(g1_fi{i}, 1)) = merda;
        g1_fi_temp(:, i) = cazzo;
    end
end
g1_fi = g1_fi_temp;
%}


g2_isi = {};
g2_isi2 = {};
g2_length = [];
g2_length2 = [];
g2_fi = {};
g2_fi_length = [];
for i = 1:length(g2)
    g2_isi{end + 1} = g2{i}.isi_rheobase';
    g2_isi2{end + 1} = g2{i}.isi_rheobase_x2';
    g2_length(end + 1) = length(g2{i}.isi_rheobase);
    g2_length2(end + 1) = length(g2{i}.isi_rheobase_x2);
    g2_fi{end + 1} = g2{i}.f_i;
    g2_fi_length(end + 1) = length(g2{i}.f_i);
end
g2_length = max(g2_length);
g2_length2 = max(g2_length2);
g2_fi_length = max(g2_fi_length);

%%{
g2_isi_temp = nan(g2_length, length(g2));
g2_isi2_temp = nan(g2_length2, length(g2));
for i = 1:length(g2)
    if isempty(g2_isi{i})
        %continue
    else
        cazzo = nan(g2_length, 1);
        cazzo(1:length(g2_isi{i})) = g2_isi{i};
        g2_isi_temp(:, i) = cazzo;
    end
    if isempty(g2_isi2{i})
        %continue
    else
        cazzo = nan(g2_length2, 1);
        cazzo(1:length(g2_isi2{i})) = g2_isi2{i};
        g2_isi2_temp(:, i) = cazzo;
    end
end
g2_isi = g2_isi_temp;
g2_isi2 = g2_isi2_temp;


g2_isi2_n = g2_isi2;
for i = 1:size(g2_isi2, 2)
    g2_isi2_n(:, i) = g2_isi2_n(:, i)./g2_isi2(1, i);
end
%}

%%{
g2_fi_temp = nan(g2_fi_length, length(g2));
for i = 1:length(g2)
    if isempty(g2_fi{i})
        %continue
    else
        cazzo = nan(g2_fi_length, 1);
        merda = g2_fi{i};
        merda = merda(:,2); % column 1 is the i_cmd (pA), starting from 0 (hence aligned)
        cazzo(1:size(g2_fi{i}, 1)) = merda;
        g2_fi_temp(:, i) = cazzo;
    end
end
g2_fi = g2_fi_temp;
%}


clear i cazzo merda
clear g1_length g1_length2 g2_length g2_length2 g1_fi_length g2_fi_length
clear g1_isi_temp g1_isi2_temp g2_isi_temp g2_isi2_temp g1_fi_temp g2_fi_temp

