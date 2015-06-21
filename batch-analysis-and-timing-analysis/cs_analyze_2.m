data3 = [];
count = 0;

if ~exist('us_vector','var')
    us_vector = 1:(size(data,3)-220);
end

if ~exist('sampling_rate','var')
    sampling_rate = 4000;
end

if size(data2,3) > 1
   for i = find(trialtypes == 10)
    count = count + 1;
    data3(count,:) = data2(:,2,i+us_vector(length(us_vector)));
    %data3(count,:) = data2(:,data2dim,i+us_vector(length(us_vector)));
    data3(count,:) = data3(count,:)  - mean(data3(count,1:sampling_rate));
    end 
else
   for i = 1:size(data2,1)
    count = count + 1;
    data3(count,:) = data2(count,:);
    %data3(count,:) = data2(:,data2dim,i+us_vector(length(us_vector)));
    data3(count,:) = data3(count,:)  - mean(data3(count,1:sampling_rate));
    end 
end

cs_only_cr = zeros(1,count);
cs_only_onset = NaN(1,count);
cs_only_peak_time = NaN(1,count);
cs_only_peak_magn = NaN(1,count);
cs_only_plus_minus_80 = NaN(2,count);
cs_only_onset2peak = NaN(1,count);
cs_only_maxvelocity = NaN(1,count);
cs_only_averagevelocity = NaN(1,count);

for j = 1:count
    if ~isempty(find(data3(j,0.82*sampling_rate+1:sampling_rate) > 0.15,1)) && isempty(find(data3(j,0.72*(sampling_rate+1):0.75*sampling_rate) > 0.05)) && max(data3(j,:)) <= 2
        cs_only_cr(j) = 1;
        cs_only_onset(j) = find(data3(j,0.82*(sampling_rate)+1:sampling_rate) >= 0.05,1)+sampling_rate;
        [cs_only_peak_magn(j),cs_only_peak_time(j)] = max(data3(j,0.82*sampling_rate+1:1.2*sampling_rate));
        cs_only_peak_time(j) = cs_only_peak_time(j) + 0.82*sampling_rate;
        cs_only_plus_minus_80(1,j) = find(data3(j,0.72*sampling_rate:cs_only_peak_time(j)) >= 0.8*cs_only_peak_magn(j),1,'first') + sampling_rate;
        cs_only_plus_minus_80(2,j) = find(data3(j,cs_only_peak_time(j):1.75*sampling_rate+1) >= 0.8*cs_only_peak_magn(j),1,'last') + cs_only_peak_time(j);
        cs_only_onset2peak(j) = cs_only_peak_time(j) - cs_only_onset(j);
        
        temp_data = [];
        for k = (0.7*sampling_rate+50):25:(sampling_rate*1.2)
            temp_data = [temp_data, mean(data3(j,(k-50):k))];
        end
        peak(1) = max(temp_data);
        peak(2) = find(temp_data==max(temp_data),1);
        if peak(2) == 1
            minn(1) = temp_data(1);
            minn(2) = 0;
        else
            for k = peak(2):-1:2
                if (temp_data(k) - temp_data(k-1)) <= 0
                    minn(1) = temp_data(k);
                    minn(2) = k;
                    break;
                elseif k == 2 && peak(2) ~= 1
                    minn(1) = temp_data(1);
                    minn(2) = 1;
                end
            end
        end
        cs_only_maxvelocity(j) = max(diff(temp_data))/(1/(sampling_rate/25));
        cs_only_averagevelocity(j) = (peak(1) - minn(1))/((peak(2) - minn(2))/(sampling_rate/25));
    end
end
