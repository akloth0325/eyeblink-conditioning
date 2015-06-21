D = dir;

if ~isequal(D(3).name,'.DS_Store')
    start_at = 3;
else
    start_at = 4;
end

for i = 1:size(D,1)
    s{i} = D(i).name;
    if isequal(s{i}(1),'d') && start_at == 0
        start_at = i;
    end
end

for q = start_at:length(s)
    load(s{q})
    disp(filename)
    if ~exist('sampling_rate')
        sampling_rate = 4000;
    end
    analysis_cr_trialbytrial_full(data2,trialtypes,filename,cs_no,sampling_rate,us_vector(length(us_vector)),'no','yes')
    D = dir;
end

clear all
close all

% for i = 1:size(D,1)
%     s{i} = D(i).name;
% end
%     title(s{q})
%     save(s{q})
% end
