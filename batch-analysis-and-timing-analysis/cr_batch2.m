
directoryname = uigetdir('Please select a directory to analyze...');
cd(directoryname)


Dr = dir;
file_list = [];
start_at = 3;

if ~isequal(Dr(3).name(end-2:end),'mat')
    start_at = 4;
end

for i = start_at:size(Dr)
    file_list(i-start_at+1,1) = str2num(Dr(i).name(1:3));
    file_list(i-start_at+1,2) = str2num(Dr(i).name(5:6));
end

animal_list = unique(file_list(:,1));
number_animals = length(animal_list);
file_grid = zeros(number_animals,4);
cr_grid = zeros(number_animals,4);

for i = 1:number_animals
    for j = 1:size(file_list,1)
        if file_list(j,1) == animal_list(i)
            file_grid(i,file_list(j,2)-3) = 1;
        end
    end
end

day4 = [];
day5 = [];
day6 = [];
day7 = [];
%day8 = [];
%day9 = [];
%day10 = [];
%day11 = [];
%day12 = [];
total = [];
mean_total = [];
sd_total = [];
animal_mean = [];
animal_sd = [];

for i = 1:number_animals
    eval(['animal',num2str(animal_list(i)),' = [];']);
end

h = waitbar(0,'Please wait...');

for i = 1:number_animals
    for j = 1:4
        waitbar(((i-1)*4+j)/(number_animals*4),h)
        if file_grid(i,j) == 1
            if animal_list(i) < 100
                if j >= 1 && j <= 4
                    if animal_list(i) < 10
                        load(['00',num2str(animal_list(i)),'-0',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    else
                        load(['0',num2str(animal_list(i)),'-0',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    end
                    disp(['0',num2str(animal_list(i)),'-0',num2str(j+3),'.mat'])
                else
                    if animal_list(i) < 10
                        load(['00',num2str(animal_list(i)),'-',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    else
                        load(['0',num2str(animal_list(i)),'-',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    end
                    disp(['0',num2str(animal_list(i)),'-',num2str(j+3),'.mat'])
                end
            else
                if j >= 1 && j <= 4
                    load([num2str(animal_list(i)),'-0',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    disp([num2str(animal_list(i)),'-0',num2str(j+3),'.mat'])
                else
                    load([num2str(animal_list(i)),'-',num2str(j+3),'.mat'],'data3','cs_only_cr')
                    disp([num2str(animal_list(i)),'-',num2str(j+3),'.mat'])
                end
            end
            sampling_rate = (size(data3,2)-1)/2;
            crs = data3(find(cs_only_cr == 1),:);
            if sampling_rate ~= 5000 && length(find(cs_only_cr == 1)) > 0
                crs2 = [];
                for q = 1:size(crs,1)
                    crs2(q,:) = resample(crs(q,:),10001,sampling_rate*2+1);
                end
                clear crs
                crs = crs2;
                clear crs2
            end
            cr_grid(i,j) = length(find(cs_only_cr == 1));
            if ~isempty(crs)
                eval(['day',num2str(j+3),' = [day',num2str(j+3),'; crs];']);
                eval(['animal',num2str(animal_list(i)),' = [animal',num2str(animal_list(i)),'; crs];']);
                total = [total;crs];
            end
            clear('data3','cs_only_cr','crs')
        end
    end
    flag = 0;
    eval(['flag = isempty(animal',num2str(animal_list(i)),');']);
    if flag == 0
        eval(['animal_mean = [animal_mean;mean(animal',num2str(animal_list(i)),')];']);
    end
end

close(h)

h = waitbar(0,'Please wait for analysis...');

animalxdate_trace = zeros(number_animals*4,10001);
animalxdate_peak = zeros(number_animals*4,2);
animalxdate_xhold = zeros(number_animals*4,1);
animalxdate_interval = zeros(number_animals*4,1);
animalxdate_maxvelocity = zeros(number_animals*4,1);
animalxdate_averagevelocity = zeros(number_animals*4,1);


for i = 1:number_animals
    for j = 1:4
        waitbar(((i-1)*4+j)/(4*number_animals),h);
        temp_peak = [];
        temp_trace = [];
        temp_xhold = [];
        temp_interval = [];
        if cr_grid(i,j) == 0 || cr_grid(i,j) <= 2
            animalxdate_trace((i-1)*4+j,:) = NaN;
            animalxdate_peak((i-1)*4+j,:) = NaN;
            animalxdate_xhold((i-1)*4+j) = NaN;
            animalxdate_interval((i-1)*4+j) = NaN;
            animalxdate_maxvelocity((i-1)*4+j) = NaN;
            animalxdate_averagevelocity((i-1)*4+j) = NaN;
        else
            for k = 1:cr_grid(i,j)
                if j == 1
                    eval(['current_trace = animal',num2str(animal_list(i)),'(k,:);']);
                else
                    eval(['current_trace = animal',num2str(animal_list(i)),'(k+sum(cr_grid(i,1:j-1)),:);']);
                end
                sampling_rate = (size(current_trace,2)-1)/2;
                temp_trace = [temp_trace; current_trace];
                [a,b] = max(current_trace((1.1*sampling_rate):(1.35*sampling_rate)));
                temp_xhold(k) = (find(current_trace((sampling_rate+1):(1.27*sampling_rate)) >= 0.05,1))/sampling_rate;
                temp_peak(k,1) = a;
                temp_peak(k,2) = (b+(0.1*sampling_rate))/sampling_rate;
                temp_interval(k) = temp_peak(k,2) - temp_xhold(k);
                temp_data = [];
                peak = [];
                minn = [];
                for p = (sampling_rate+50):25:(sampling_rate*1.5)
                    temp_data = [temp_data, mean(current_trace((p-50):p))];
                end
                peak(1) = max(temp_data);
                peak(2) = find(temp_data==max(temp_data),1);
                if peak(2) == 1
                    minn(1) = temp_data(1);
                    minn(2) = 0;
                else
                    for p = peak(2):-1:2
                        if (temp_data(p) - temp_data(p-1)) <= 0
                            minn(1) = temp_data(p);
                            minn(2) = p;
                            break;
                        elseif p == 2 && peak(2) ~= 1
                            minn(1) = temp_data(1);
                            minn(2) = 1;
                        end
                    end
                end
                temp_maxvelocity(k) = max(diff(temp_data))/(1/(sampling_rate/25));
                temp_averagevelocity(k) = (peak(1) - minn(1))/((peak(2) - minn(2))/(sampling_rate/25));
            end
            animalxdate_peak((i-1)*4+j,1) = mean(temp_peak(:,1));
            animalxdate_peak((i-1)*4+j,2) = mean(temp_peak(:,2));
            animalxdate_xhold((i-1)*4+j) = mean(temp_xhold);
            animalxdate_trace((i-1)*4+j,:) = mean(temp_trace);
            animalxdate_interval((i-1)*4+j) = mean(temp_interval);
            animalxdate_maxvelocity((i-1)*4+j) = mean(temp_maxvelocity);
            animalxdate_averagevelocity((i-1)*4+j) = mean(temp_averagevelocity);
        end
    end
end

close(h)

filename = input('Please enter a file name without the extension.', 's');
save(filename)
clear all

