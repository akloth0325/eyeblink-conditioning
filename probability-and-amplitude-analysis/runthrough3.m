D = dir;

for i = 1:size(D,1)
    DZZZ{i} = D(i).name;
end

B = length(DZZZ);

if ~isequal(D(3).name,'.DS_Store')
    start_at2 = 3;
else
    start_at2 = 4;
end

%output = zeros(B-2,23);
HG1 = zeros(B-start_at2+1,length(-1:0.05:1));
HG2 = zeros(B-start_at2+1,length(3181:20:3750));
noise_t = [];
noise_c = [];
amp_range = -1:0.05:1;

for z = start_at2:B
    z;
    load(DZZZ{z},'all_response_vector','data2','sampling_rate','us_vector')
    D = dir;
    DZZZ = {};
    for i = 1:size(D,1)
        DZZZ{i} = D(i).name;
    end
    data2 = squeeze(data2(:,2,:));
    HG1(z-start_at2+1,:) = histc(all_response_vector(:,3),amp_range); % cumulative histogram of peak times, US-CS trials
    HG2(z-start_at2+1,:) = histc(all_response_vector(:,2),3181:20:3750); % cumulative histogram of peak magnitudes, US-CS trials
    if z == start_at2
        noise_t = [noise_t;zeros(1,220)];
    else
        noise_t = [noise_t;zeros(1,size(noise_t,2))];
    end
    for j = (us_vector(end)+1):size(data2,2)
        noise_t(size(noise_t,1),j-us_vector(end)) = max(data2(round(sampling_rate*0.75):round(sampling_rate*0.99),j));
    end
    noise_c = [noise_c;histc(reshape(data2(round(sampling_rate*0.75):round(sampling_rate*0.99),:),1,numel(data2(round(sampling_rate*0.75):round(sampling_rate*0.99),:))),amp_range)];
    clear all_response_vector data2 sampling_rate us_vector
end

all_names = DZZZ;

AA = B - start_at2 + 1
