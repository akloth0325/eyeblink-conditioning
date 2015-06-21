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
%         peak = [];
%         minn = [];
        for q = 51:10:(sampling_rate-1)
            temp_data2 = [temp_data2, mean(current_trace((q-50):q))];
        end
        for p = (sampling_rate):10:(sampling_rate*1.5)
            temp_data = [temp_data, mean(current_trace((p-50):p))];
        end
%         peak(1) = max(temp_data);
%         peak(2) = find(temp_data==max(temp_data),1);
%         if peak(2) == 1
%                     minn(1) = temp_data(1);
%                     minn(2) = 0;
%                 else
%                     for p = peak(2):-1:2
%                         if (temp_data(p) - temp_data(p-1)) <= 0
%                             minn(1) = temp_data(p);
%                             minn(2) = p;
%                             break;
%                         elseif p == 2 && peak(2) ~= 1
%                             minn(1) = temp_data(1);
%                             minn(2) = 1;
%                         end
%                     end
%                 end
%        [x,y] = max(diff(temp_data));
%        temp_maxvelocity(k,1) = x/(1/(sampling_rate/25));
%        temp_maxvelocity(k,2) = y/(sampling_rate/25);
%        temp_averagevelocity(k) = (peak(1) - minn(1))/((peak(2) - minn(2))/(sampling_rate/25));
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
        %temp_onset_time(k) = (find(temp_matrix(k,(1.1*sampling_rate):(2*sampling_rate)) > 0.05,1)+0.1*sampling_rate)/sampling_rate;
    end
    
    animal_matrix1(j,:) = cumsum(histc(temp_peak_time,0:0.01:1.5)/size(temp_matrix,1)); 
    animal_stats1(j,1) = median(temp_peak_time(find(temp_peak_magn <= 1.5))); % peak time
    animal_stats1(j,2) = std(temp_peak_time(find(temp_peak_magn <= 1.5)));
    animal_stats1(j,3) = length((find(temp_peak_magn <= 1.5)));
    animal_matrix2(j,:) = cumsum(histc(temp_peak_magn(find(temp_peak_magn <= 1.5)),0:0.1:1)/length(find(temp_peak_magn <= 1.5)));
    animal_stats2(j,1) = median(temp_peak_magn(find(temp_peak_magn <= 1.5))); % peak magnitude
    animal_stats2(j,2) = std(temp_peak_magn(find(temp_peak_magn <= 1.5)));
    animal_stats2(j,3) = length(find(temp_peak_magn <= 1.5));
    %animal_matrix3(j,:) = cumsum(histc(temp_onset_time(find(temp_peak_magn <= 1.5)),0:0.01:1.5)/length((find(temp_peak_magn <= 1.5))));
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
%    animal_matrix5(j,:) = cumsum(histc(temp_maxvelocity((find(temp_peak_magn <= 1.5)),1),0:1:400)/length((find(temp_peak_magn <= 1.5)))); %removed cumsum
%    animal_matrix6(j,:) = cumsum(histc(temp_averagevelocity(find(temp_peak_magn <= 1.5)),0:1:400)/length((find(temp_peak_magn <= 1.5)))); %removed cumsum
%    animal_matrix7(j,:) = cumsum(histc(temp_maxvelocity((find(temp_peak_magn <= 1.5)),2),0:0.01:1.5)/length((find(temp_peak_magn <= 1.5)))); %removed cumsum
%    animal_stats5(j,1) = mean(temp_maxvelocity((find(temp_peak_magn <= 1.5)),1)); % value of maximum velocity
%    animal_stats5(j,2) = std(temp_maxvelocity((find(temp_peak_magn <= 1.5)),1));
%    animal_stats5(j,3) = size(temp_maxvelocity((find(temp_peak_magn <= 1.5)),1),1);
%    animal_stats7(j,1) = mean(temp_maxvelocity((find(temp_peak_magn <= 1.5)),2)); % time of maximum velocity
%    animal_stats7(j,2) = std(temp_maxvelocity((find(temp_peak_magn <= 1.5)),2));
%    animal_stats7(j,3) = size(temp_maxvelocity((find(temp_peak_magn <= 1.5)),2),1);
%    animal_stats6(j,1) = mean(temp_averagevelocity(find(temp_peak_magn <= 1.5))); % value of average velocity
%    animal_stats6(j,2) = std(temp_averagevelocity(find(temp_peak_magn <= 1.5)));
%    animal_stats6(j,3) = size(temp_averagevelocity(find(temp_peak_magn <= 1.5)),1);
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

% new_animal_matrix1 = [];
% new_animal_matrix2 = [];
% new_animal_matrix3 = [];
% new_animal_matrix4 = [];
% new_animal_matrix5 = [];
% new_animal_matrix6 = [];
% new_animal_matrix7 = [];
% c = 0:0.01:1.5;
% c2 = 0:0.1:1;
% c3 = 0:400;
% temp_matrix1 = mean(animal_matrix1);
% temp_m1_sem = std(animal_matrix1)/sqrt(size(animal_matrix1,1));
% temp_matrix3 = mean(animal_matrix3);
% temp_m2_sem = std(animal_matrix2)/sqrt(size(animal_matrix2,1));
% temp_matrix4 = mean(animal_matrix4);
% temp_m3_sem = std(animal_matrix3)/sqrt(size(animal_matrix3,1));
% temp_matrix2 = mean(animal_matrix2);
% temp_m4_sem = std(animal_matrix4)/sqrt(size(animal_matrix4,1));
% temp_matrix5 = mean(animal_matrix5);
% temp_matrix6 = mean(animal_matrix6);
% temp_m5_sem = std(animal_matrix5)/sqrt(size(animal_matrix5,1));
% temp_m6_sem = std(animal_matrix6)/sqrt(size(animal_matrix6,1));
% temp_matrix7 = mean(animal_matrix7);
% temp_m7_sem = std(animal_matrix7)/sqrt(size(animal_matrix7,1));
% 
% for q = 2:length(c)
%     new_animal_matrix1 = [new_animal_matrix1,c(q)*ones(1,round((temp_matrix1(q)-temp_matrix1(q-1))*100))];
%     new_animal_matrix3 = [new_animal_matrix3,c(q)*ones(1,round((temp_matrix3(q)-temp_matrix3(q-1))*count))];
%     new_animal_matrix4 = [new_animal_matrix4,c(q)*ones(1,round((temp_matrix4(q)-temp_matrix4(q-1))*count))];
%     new_animal_matrix7 = [new_animal_matrix7,c(q)*ones(1,round((temp_matrix7(q)-temp_matrix7(q-1))*count))];
%     new_animal_matrix6 = [new_animal_matrix6,c(q)*ones(1,round((temp_matrix6(q)-temp_matrix6(q-1))*count))];
% end
% 
% for q = 2:length(c2)
%    new_animal_matrix2 = [new_animal_matrix2,c2(q)*ones(1,round((temp_matrix2(q)-temp_matrix2(q-1))*count))];
% end 
% 
% for q = 2:length(c3)
%     new_animal_matrix6 = [new_animal_matrix6,c3(q)*ones(1,round((temp_matrix6(q)-temp_matrix6(q-1))*count))];
%     new_animal_matrix5 = [new_animal_matrix5,c3(q)*ones(1,round((temp_matrix5(q)-temp_matrix5(q-1))*count))];
% end
% 
% % for i = 1:342
% %     [a,b] = max(all_animals(i,5500:10000));
% %     all_peak_magn(i) = a;
% %     all_peak_time(i) = (b+500)/5000;
% % end

