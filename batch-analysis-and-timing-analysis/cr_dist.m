count = 0;

animal_stats1 = [];
animal_stats2 = [];
animal_stats3 = [];
animal_stats4 = [];
animal_stats5 = [];
animal_stats6 = [];
animal_stats7 = [];
animal_stats8 = [];

for j = 1:(length(animal_list))
    temp_peak_magn = [];
    temp_peak_time = [];
    temp_onset_time = [];
    temp_onset_value = [];
    temp_maxvelocity = [];
    temp_averagevelocity = [];
    temp_10time = [];
    temp_90time = [];
    temp_1090time = [];
    eval(['temp_matrix = animal',num2str(animal_list(j)),';']);
    sampling_rate = (size(temp_matrix,2) - 1)/2;
    count = count + size(temp_matrix,1);
    for k = 1:size(temp_matrix,1)
        current_trace = temp_matrix(k,:);
        temp_data = [];
        temp_data2 = [];
        for q = 51:10:(sampling_rate-1)
            temp_data2 = [temp_data2, mean(current_trace((q-50):q))];
        end
        for p = (sampling_rate):10:(sampling_rate*1.5)
            temp_data = [temp_data, mean(current_trace((p-50):p))];
        end
        [a,b] = max(temp_data);
        temp_peak_magn(k) = a;
        temp_peak_time(k) = b/(sampling_rate/10);
        if isempty((find(temp_data >= (mean(temp_data2)+3*std(temp_data2)),1)+1)/(sampling_rate/10))
            temp_onset_time(k) = NaN;
            temp_onset_value(k) = NaN;
        else
            temp_onset_time(k) = (find(temp_data >= (mean(temp_data2)+3*std(temp_data2)),1)+1)/(sampling_rate/10);
            temp_onset_value(k) = mean(temp_data2)+3*std(temp_data2);
        end
        temp_10time(k) = (find((temp_data-mean(temp_data2))/(max(temp_data)-mean(temp_data2)) >= 0.10,1))/(sampling_rate/10);
        temp_90time(k) = (find((temp_data-mean(temp_data2))/(max(temp_data)-mean(temp_data2)) >= 0.90,1))/(sampling_rate/10);
        temp_1090time(k) = temp_90time(k) - temp_10time(k);
    end
    
    animal_matrix1(j,:) = cumsum(histc(temp_peak_time,0:0.01:1.5)/size(temp_matrix,1)); 
    animal_stats1(j,1) = median(temp_peak_time(find(temp_peak_magn <= 1.5))); % peak time
    animal_stats1(j,2) = std(temp_peak_time(find(temp_peak_magn <= 1.5)));
    animal_stats1(j,3) = length((find(temp_peak_magn <= 1.5)));
    animal_matrix2(j,:) = cumsum(histc(temp_peak_magn(find(temp_peak_magn <= 1.5)),0:0.1:1)/length(find(temp_peak_magn <= 1.5)));
    animal_stats2(j,1) = median(temp_peak_magn(find(temp_peak_magn <= 1.5))); % peak magnitude
    animal_stats2(j,2) = std(temp_peak_magn(find(temp_peak_magn <= 1.5)));
    animal_stats2(j,3) = length(find(temp_peak_magn <= 1.5));
    animal_stats3(j,1) = median(temp_onset_time(intersect(find(~isnan(temp_onset_time)),find(temp_peak_magn <= 1.5)))); % onset time
    animal_stats3(j,2) = std(temp_onset_time(intersect(find(~isnan(temp_onset_time)), find(temp_peak_magn <= 1.5))));
    animal_stats3(j,3) = length(intersect(find(~isnan(temp_onset_time)),(find(temp_peak_magn <= 1.5))));
    animal_matrix4(j,:) = cumsum(histc(temp_peak_time(find(temp_peak_magn <= 1.5))-temp_onset_time(find(temp_peak_magn <= 1.5)),0:0.01:1.5)/length(find(temp_peak_magn <= 1.5))); %removed cumsum
    animal_stats4(j,1) = median(temp_peak_time(find(temp_peak_magn <= 1.5))-temp_onset_time(find(temp_peak_magn <= 1.5))); % rise time
    animal_stats4(j,2) = std(temp_peak_time(find(temp_peak_magn <= 1.5))-temp_onset_time(find(temp_peak_magn <= 1.5)));
    animal_stats4(j,3) = length((find(temp_peak_magn <= 1.5)));
    animal_stats5(j,1) = median(temp_onset_value(intersect(find(~isnan(temp_onset_value)),find(temp_peak_magn <= 1.5))));
    animal_stats5(j,2) = std(temp_onset_value(intersect(find(~isnan(temp_onset_value)),find(temp_peak_magn <= 1.5))));
    animal_stats5(j,3) = length(intersect(find(~isnan(temp_onset_value)),find(temp_peak_magn<=1.5)));
    animal_stats8(j,1) = median(temp_1090time(find(temp_peak_magn <= 1.5)));
    animal_stats8(j,2) = std(temp_1090time(find(temp_peak_magn <= 1.5)));
    animal_stats8(j,3) = size(temp_1090time(find(temp_peak_magn <= 1.5)),2);
end

animal_stats1 = animal_stats1';
animal_stats2 = animal_stats2';
animal_stats3 = animal_stats3';
animal_stats4 = animal_stats4';
animal_stats5 = animal_stats5';
animal_stats6 = animal_stats6';
animal_stats7 = animal_stats7';
animal_stats8 = animal_stats8';

