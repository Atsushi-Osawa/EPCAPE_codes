%% EPCAPE_SEMS_APS_merge_v20250628.m
%
% PURPOSE: Reads in EPCAPE SEMS and APS data, computes averages, and merges
% the size distributions following Khlystov (2004) and Modini et al.
% (2015). 
%
% INPUTS: hourly averaged SEMS and APS data.
%
% OUTPUTS: .MAT files of merged size distributions and CVI size
% distributions. 
%
% AUTHOR: Jeramy Dedrick
%         Scripps Institution of Oceanography
%         July 24, 2023
%         
% EDITED: Ian Marroquin 
%         Washington University in St. Louis
%         August 15, 2023
%         
% 
% Note 1: I adjusted this file such that the input is already averaged hourly
% size distributions. Here, only the diameter is used from the febmar23.nc
% files. Also, even though the variables correspond to hourly distributions
% they are named _15min etc. Finally, line 101 is hard coded (1008 hourly size
% distributions translate to 42 days), yet may be easily corrected/adjusted.

% Note 2: The sems_hourly.csv and aps_hourly.csv are essentially generated
% by combining the individual sems files (see under the averaging_function_gamma)
% into one larger .csv file (same procedure for aps).
%
%
% EDITED: Jeramy Dedrick
%         Scripps Institution of Oceanography
%         August 16, 2023
%
% Note 1: Re-added averaging of size distributions. Set up code to search
% files within processing directory for SEMS and APS. 
%
%
% EDITED: Jeramy Dedrick
%         Scripps Institution of Oceanography
%         October 11, 2023
%
% Note 1: added 15 min average mergers. Added 5-min averages (Oct. 14)
%
%
% EDITED: Jeramy Dedrick
%         Scripps Institution of Oceanography
%         November 13, 2023
%
% Note 1: added lines to remove negative data points in merged size
% distribution. 
% EDITED: Atsushi Osawa
%         Scripps Instituion of Oceanography
%         Juluy 16,2024
% Note 1: Adjusted line for intersect to account for the discrenpancy error
% with matching APS and SEMS time. Added flag variables for five minute
% merging section
% EDITED: Atsushi Osawa
%         Scripps Institution of Oceanography
%         June 28 2025
%         Asjusted code for only 5 minute distribution merging
% 

clear all; close all; clc

%% load data

% data folder
data    = '/Users/atsushiosawa/EPCAPE_Files/Data_Soledad'; %file name for the user
% output folder
out_dir = '/Users/atsushiosawa/EPCAPE_Files/output/';  %file name for the user

% identifies files 
SEMS_files = dir(fullfile(strcat(data,'/SEMS_data_out/'),'EPCAPE*.nc'));

% identifies files 
APS_files = dir(fullfile(strcat(data,'/APS_data_out'),'EPCAPE*.nc'));



%% Read in data

disp(strcat('Opening and reading SEMS & APS files'))


% empty matrices for concatenationloan(
SEMS_time = [];
SEMS_PNSD = [];
SEMS_Ntot = [];
SEMS_qc   = [];
SEMS_cvi  = [];

APS_time = [];
APS_PNSD = [];
APS_Ntot = [];
APS_qc   = [];
%% 

for i = 1:length(SEMS_files)

    % creates file strings
    SEMS_file = strcat(SEMS_files(i).folder, '/', SEMS_files(i).name);
    APS_file  = strcat(APS_files(i).folder, '/', APS_files(i).name); 

    % read data
    SEMS_time_r = ncread(SEMS_file, 'time')';
    SEMS_PNSD_r = ncread(SEMS_file, 'PNSD');
    SEMS_Ntot_r = ncread(SEMS_file, 'Ntot')';
    SEMS_d_mid  = ncread(SEMS_file, 'diam_mid');
    SEMS_qc_r   = ncread(SEMS_file, 'qc')';
    SEMS_cvi_r  = ncread(SEMS_file, 'cvi_flag')';
    

    APS_time_r = ncread(APS_file, 'time')';
    APS_PNSD_r = ncread(APS_file, 'PNSD');
    APS_Ntot_r = ncread(APS_file, 'Ntot')';
    APS_d_mid  = ncread(APS_file, 'diam_mid');
    APS_qc_r   = ncread(APS_file, 'APS_qc')';

    % quality control (only want QC = 1)
    % SEMS_PNSD_r(:,SEMS_qc<1) = NaN;
    % SEMS_Ntot_r(SEMS_qc<1)   = NaN;
    % APS_PNSD_r(:,APS_qc<1)  = NaN;
    % APS_Ntot_r(APS_qc<1)    = NaN;

    % concatenate
    SEMS_time = [SEMS_time SEMS_time_r];
    SEMS_PNSD = [SEMS_PNSD SEMS_PNSD_r];
    SEMS_Ntot = [SEMS_Ntot SEMS_Ntot_r];
    SEMS_qc   = [SEMS_qc SEMS_qc_r];
    SEMS_cvi  = [SEMS_cvi, SEMS_cvi_r];

    APS_time = [APS_time APS_time_r];
    APS_PNSD = [APS_PNSD APS_PNSD_r];
    APS_Ntot = [APS_Ntot APS_Ntot_r];
    APS_qc   = [APS_qc APS_qc_r];

end

%% sort so that time increases
[SEMS_time_sort, SEMS_time_sort_idx] = sort(SEMS_time, 'ascend');
[APS_time_sort, APS_time_sort_idx]   = sort(APS_time, 'ascend');

SEMS_time = SEMS_time(SEMS_time_sort_idx);
SEMS_PNSD = SEMS_PNSD(:,SEMS_time_sort_idx);
SEMS_Ntot = SEMS_Ntot(SEMS_time_sort_idx);
SEMS_cvi  = SEMS_cvi(SEMS_time_sort_idx);
SEMS_qc   = SEMS_qc(SEMS_time_sort_idx);

APS_time = APS_time(APS_time_sort_idx);
APS_PNSD = APS_PNSD(:,APS_time_sort_idx);
APS_Ntot = APS_Ntot(APS_time_sort_idx);
APS_qc   = APS_qc(APS_time_sort_idx);


SEMS_PNSD(:,SEMS_qc < 1)    = NaN;
SEMS_Ntot(SEMS_qc < 1)      = NaN;
SEMS_PNSD(:,isnan(SEMS_qc)) = NaN;
SEMS_Ntot(isnan(SEMS_qc))   = NaN;

APS_PNSD(:,APS_qc < 1)    = NaN;
APS_Ntot(APS_qc < 1)      = NaN;
APS_PNSD(:,isnan(APS_qc)) = NaN;
APS_Ntot(isnan(APS_qc))   = NaN;



%% Average over time intervals
clc

disp('Averaging size distributions')

min05  = 0:5:60;  % 5 min intervals in an hour

hours  = 0:23;    % hours in a day (for hourly averages)

% number of unique data days
SEMS_days = unique(floor(SEMS_time));
APS_days  = unique(floor(APS_time));
days      = intersect(SEMS_days, APS_days);

%% common time between SEMS and APS 
[common_time,...
 common_time_idx_SEMS,...
 common_time_idx_APS] = intersect(SEMS_time, APS_time);
%% 

SEMS_PNSD                      = SEMS_PNSD(:,common_time_idx_SEMS);
SEMS_Ntot                      = SEMS_Ntot(:,common_time_idx_SEMS);
SEMS_cvi                       = SEMS_cvi(common_time_idx_SEMS);
SEMS_PNSD_cvi                  = NaN(length(SEMS_d_mid), length(common_time_idx_SEMS));
SEMS_PNSD_cvi(:,SEMS_cvi > 0)  = SEMS_PNSD(:,SEMS_cvi > 0);
SEMS_Ntot_cvi                  = NaN(1,length(common_time_idx_SEMS));
SEMS_Ntot_cvi(:,SEMS_cvi > 0)  = SEMS_Ntot(:,SEMS_cvi > 0);
APS_PNSD                       = APS_PNSD(:, common_time_idx_APS);
APS_Ntot                       = APS_Ntot(common_time_idx_APS);
%% 

% empty matrices for concatenating
SEMS_PNSD_5min      = [];
SEMS_cvi_5min       = [];
SEMS_PNSD_cvi_5min  = [];
SEMS_Ntot_5min      = [];
SEMS_Ntot_cvi_5min  = [];
APS_PNSD_5min       = [];
APS_Ntot_5min       = [];
time_5min           = [];


SEMS_PNSD_hr      = [];
SEMS_cvi_hr       = [];
SEMS_PNSD_cvi_hr  = [];
SEMS_Ntot_hr      = [];
SEMS_Ntot_cvi_hr  = [];
APS_PNSD_hr       = [];
APS_Ntot_hr       = [];
time_hr           = [];

%% 

for i = 1:length(days)

    % find each day
    day_find = find(floor(common_time) == days(i));


    % get the data and times for each day
    SEMS_PNSD_day         = SEMS_PNSD(:,day_find);
    SEMS_Ntot_day         = SEMS_Ntot(day_find);
    SEMS_cvi_day          = SEMS_cvi(day_find);
    SEMS_PNSD_cvi_day     = SEMS_PNSD_cvi(:,day_find);
    SEMS_Ntot_cvi_day     = SEMS_Ntot_cvi(day_find);
    APS_PNSD_day          = APS_PNSD(:,day_find);
    APS_Ntot_day          = APS_Ntot(day_find);
    time_day_find_datevec = datevec(common_time(day_find));


    for j = 1:length(hours) 
  
        % index of data that match hour 
        hrly_idx = find(time_day_find_datevec(:,4) == hours(j));
        
        % hourly time
        time_hrly(1,j) = datenum([time_day_find_datevec(1,1:3), ...
                                  hours(j),0,0]); 
            

        % 5-min time
        time_5min_r = datenum([repmat(time_day_find_datevec(1,1:3),12,1), ...
                                    repmat(hours(j),12,1), ...
                                    min05(1:end-1)', ...
                                    zeros(12,1)]);  

        time_5min = [time_5min time_5min_r'];

        % if the file doesn't have that hour, replace with NaN                        
        if isempty(hrly_idx)
            
           SEMS_PNSD_hrly(:,j)     = NaN(length(SEMS_d_mid),1); 
           SEMS_Ntot_hrly(:,j)     = NaN(1,1);
           SEMS_cvi_hrly(:,j)      = NaN(1,1);
           SEMS_PNSD_cvi_hrly(:,j) = NaN(1,1);
           SEMS_Ntot_cvi_hrly(:,j) = NaN(1,1);
           APS_PNSD_hrly(:,j)      = NaN(length(APS_d_mid),1);
           APS_Ntot_hrly(:,j)      = NaN(1,1);

           SEMS_PNSD_5min_r      = NaN(length(SEMS_d_mid), 12);
           SEMS_cvi_5min_r       = NaN(1,1);
           SEMS_PNSD_cvi_5min_r  = NaN(1,1);
           SEMS_Ntot_5min_r      = NaN(1,1);
           SEMS_Ntot_cvi_5min_r  = NaN(1,1);
           APS_PNSD_5min_r       = NaN(length(APS_d_mid), 12);
           APS_Ntot_5min_r       = NaN(1,1);
           
        % if hour exists, grab data for that hour and compute average
        else
            
           % grabs data for specified hour
           SEMS_PNSD_hr_get     = SEMS_PNSD_day(:,hrly_idx);
           SEMS_Ntot_hr_get     = SEMS_Ntot_day(hrly_idx);
           SEMS_cvi_hr_get      = SEMS_cvi_day(hrly_idx);
           SEMS_PNSD_cvi_hr_get = SEMS_PNSD_cvi_day(:,hrly_idx);
           SEMS_Ntot_cvi_hr_get = SEMS_Ntot_cvi_day(hrly_idx);
           APS_PNSD_hr_get      = APS_PNSD_day(:,hrly_idx);
           APS_Ntot_hr_get      = APS_Ntot_day(hrly_idx);
           time_hr_get          = time_day_find_datevec(hrly_idx,:);

      
            
           % 5-minute average
            for k = 1:length(min05)-1

                min05_find = find(time_hr_get(:,5) >= min05(k) & ...
                                  time_hr_get(:,5) < min05(k+1));
            
                if isempty(min05_find)
    
                    SEMS_PNSD_5min_r(:,k)        = NaN(length(SEMS_d_mid),1);
                    SEMS_Ntot_5min_r(:,k)        = NaN(1,1);
                    SEMS_cvi_5min_r(:,k)         = NaN(1,1);
                    SEMS_PNSD_cvi_5min_r(:,k)    = NaN(length(SEMS_d_mid),1);
                    SEMS_Ntot_cvi_5min_r(:,k)    = NaN(1,1);
                    APS_PNSD_5min_r(:,k)         = NaN(length(APS_d_mid),1);
                    APS_Ntot_5min_r(:,k)         = NaN(1,1);
    
                else
    
                    SEMS_PNSD_5min_r(:,k)        = nanmean(SEMS_PNSD_hr_get(:,min05_find,:),2);
                    SEMS_Ntot_5min_r(:,k)        = nanmean(SEMS_Ntot_hr_get(min05_find));
                    SEMS_cvi_5min_r(:,k)         = nanmean(SEMS_cvi_hr_get(min05_find));
                    SEMS_PNSD_cvi_5min_r(:,k)    = nanmean(SEMS_PNSD_cvi_hr_get(:,min05_find,:),2);
                    SEMS_Ntot_cvi_5min_r(:,k)    = nanmean(SEMS_Ntot_cvi_hr_get(min05_find));
                    APS_PNSD_5min_r(:,k)         = nanmean(APS_PNSD_hr_get(:,min05_find),2);
                    APS_Ntot_5min_r(:,k)         = nanmean(APS_Ntot_hr_get(min05_find));

    
                end

            end

                                                         
    end



        SEMS_PNSD_5min     = [SEMS_PNSD_5min SEMS_PNSD_5min_r];
        SEMS_Ntot_5min     = [SEMS_Ntot_5min SEMS_Ntot_5min_r];
        SEMS_cvi_5min      = [SEMS_cvi_5min SEMS_cvi_5min_r];
        SEMS_PNSD_cvi_5min = [SEMS_PNSD_cvi_5min SEMS_PNSD_cvi_5min_r];
        SEMS_Ntot_cvi_5min = [SEMS_Ntot_cvi_5min SEMS_Ntot_cvi_5min_r];
        APS_PNSD_5min      = [APS_PNSD_5min APS_PNSD_5min_r];
        APS_Ntot_5min      = [APS_Ntot_5min APS_Ntot_5min_r];
                    

    end
end;



% remove SEMS PNSD if sampling switched to CVI at any point during the
% average
SEMS_PNSD_5min(:,SEMS_cvi_5min > 0)   = NaN;


SEMS_Ntot_5min(SEMS_cvi_5min > 0)   = NaN;



disp('Done averaging size distributions')

%% Merge 5-min SEMS and APS
clc

%%%%%%%%%%%%%%%%% Setting/Getting Parameters and Indices %%%%%%%%%%%%%%%%%%

% log-spaced diameter grid to merge over (10 nm - 10 micron)
D_merged = logspace(log10(SEMS_d_mid(2)), log10(10), 100)';

% dlogDp of diameters
dlogDp_merged = log10(D_merged(50)) - log10(D_merged(49));

% indices of SEMS tail (visual)
SEMS_tail_idx  = 52:58; %52:58(original) %50:58(proposed)

% diameters of SEMS tail
SEMS_d_tail    = SEMS_d_mid(SEMS_tail_idx); 

% smoothing window (points)
SEMS_smooth_window = 3;
APS_smooth_window  = 3;

% indices for which to grab SEMS for merger with APS
SEMS_d_to_merge_idx = 1:54; %1:58; 

% indices of APS that overlap with the SEMS
overlap_idx = 3:9;
overlap_d   = APS_d_mid(overlap_idx);

% diameters of SEMS that merge with APS
SEMS_d_merge_idx = 55:60;%55:60
SEMS_d_merge = SEMS_d_mid(SEMS_d_merge_idx);

% density values to test (g cm-3) (Modini et al., 2015)
rho_test = 0.9:0.01:3.0;

% shape factor
chi_shape = 1;

% reference density (g cm-3)
rho_0 = 1;

%%added flag today
flag=NaN(1,length(time_5min)); % flag varaible
SEMS_fit_plot=NaN(length(SEMS_d_tail),length(time_5min));
stored_SEMS_fit_r2=NaN(1,length(time_5min));% should address r2=0 issues
%%%%%%%%%%%%%%%%%% Merging the size distributoins %%%%%%%%%%%%%%%%%%%%%%%%%

%% 


for i = 1:length(time_5min)

    disp(strcat('Merging SEMS+APS, 5-min: ', num2str(i), '/', num2str(length(time_5min))))

    % check if size distributions exist for the specified time period
    SEMS_check      = all(isnan(SEMS_PNSD_5min(:,i)));
 
    APS_check       = all(isnan(APS_PNSD_5min(:,i)));
    
    if APS_check>0 & SEMS_check>0;
        flag(2,i)=3;
    elseif APS_check>0;
        flag(2,i)=2;
    elseif SEMS_check>0;
        flag(2,i)=1;
    end;



    size_dist_check = SEMS_check + APS_check;
   

    if size_dist_check > 0 % at least one size distribution missing

        PNSD_merged_5min(:,i) = NaN(length(D_merged),1);
        Nt_merged_5min(:,i)   = NaN(1,1);
        rho_merge_5min(:,i)   = NaN(1,1);

        flag(1,i)=1;
        
  

    else

        % fix weird bins between 0.5 and 1 micron by spline interpolation 
        APS_interp_sizes         = APS_PNSD_5min(:,i);
        APS_interp_sizes(2:13,:) = NaN;
        APS_interp_sizes(isnan(APS_interp_sizes)) = interp1(APS_d_mid(~isnan(APS_interp_sizes)), ...
                                                            APS_interp_sizes(~isnan(APS_interp_sizes)), ...
                                                            APS_d_mid(isnan(APS_interp_sizes)), 'spline', 'extrap');

        % SEMS size distribution in tail
        SEMS_PNSD_tail = SEMS_PNSD_5min(SEMS_tail_idx,i);

        % Fit power law to tail of SMPS
        [SEMS_fit, SEMS_fit_gof] = fit(SEMS_d_tail, ... 
                                       movmean(SEMS_PNSD_tail, SEMS_smooth_window), ... % tail of SEMS smoothed
                                       'power1');

        SEMS_fit_params = coeffvalues(SEMS_fit); % coefficients from fit
        SEMS_fit_r2     = SEMS_fit_gof.rsquare;  % fit R^2
        stored_SEMS_fit_r2(1,i)=SEMS_fit_r2;
        

        %added 7/9 making a variable that will have fitted line in it
        SEMS_fit_plot(:,i)=(SEMS_fit_params(1)).*((SEMS_d_tail).^(SEMS_fit_params(2)));

       


        if SEMS_fit_r2 < 0.70 % SEMS too noisy to fit a power law tail (subjective R2)
% maybe try lowering the r squared threshld value here
% histogram of the r squared value?
%5 was changed to 0.7
            PNSD_merged_5min(:,i) = NaN(length(D_merged),1);
            Nt_merged_5min(:,i)   = NaN(1,1);
            rho_merge_5min(:,i)   = NaN(1,1);

            flag(1,i)=2;

        elseif SEMS_fit_params(1) == 0 % if there's no fit

            PNSD_merged_5min(:,i) = NaN(length(D_merged),1);
            Nt_merged_5min(:,i)   = NaN(1,1);
            rho_merge_5min(:,i)   = NaN(1,1);

            flag(1,i)=3;

        else

            S2 = [];
            % Test density  
            for k = 1:length(rho_test)

                % convert aerodynamic diameter to geometric physical diameter
                APS_d_phys = APS_d_mid(overlap_idx) ./ ...
                             sqrt(rho_test(k) / (chi_shape .* rho_0));

                % compute objective function in overlap region (S^2, Khlystov 2004)
                S2(:,k) = sum((log10( SEMS_fit_params(1) .* APS_d_phys .^ SEMS_fit_params(2) ) - ...
                          log10(movmean(APS_interp_sizes(overlap_idx), APS_smooth_window))).^2);% ./ ...
                          % (length(overlap_idx)-1);

                % objective function not a real value          
                if isinf(S2(:,k))

                    S2(:,k) = NaN;

                    flag(1,i)=4;

                else

                    S2(:,k) = S2(:,k);

                end  

            end

            % stop the merger if can't find a minimum of objective
            % function
            if all(isnan(S2))
    
                PNSD_merged_5min(:,i) = NaN(length(D_merged),1);
                Nt_merged_5min(:,i)   = NaN(1,1);
                rho_merge_5min(:,i)   = NaN(1,1);

                flag(1,i)=5;
    
            else
                flag(1,i)=0; %0 for no flags
    
            % minimum value of objective function
            S2min_5min = nanmin(S2);

            % density at minimum value of objective function
            rho_merge_5min(i) = rho_test(S2 == nanmin(S2));

            % shifted APS diameter using effective density
            APS_diam_new =  APS_d_mid ./ ...
                            sqrt(rho_merge_5min(i) / (chi_shape .* rho_0));

            % APS diameters to merge APS with SEMS (find between
            % 0.7 to 11 micorn
            % APS_d_merge_idx = find(APS_diam_new >= 0.75 & ...
            %                        APS_diam_new <= 11);

            % APS diameters to merge APS with SEMS (find between
            % 0.7 to 11 micorn
            APS_d_merge_idx = 12:45;


            % merged SEMS and shifted APS diameters
            d_merged_SEMS_APS = [SEMS_d_mid(SEMS_d_to_merge_idx); APS_diam_new(APS_d_merge_idx)];

            % merged size distributions 
            PNSD_merged_r = [SEMS_PNSD_5min(SEMS_d_to_merge_idx,i); APS_interp_sizes(APS_d_merge_idx)];

            % interpolating merged size distribution onto diameter grid
            PNSD_merged_5min(:,i) = interp1(d_merged_SEMS_APS, PNSD_merged_r, D_merged);

            % merged total number concentration
            Nt_merged_5min(:,i) = nansum(PNSD_merged_5min(:,i) .* dlogDp_merged,1);

            end

        end

    end

    end


%% Remove Merged Distributions where there are negative values %run this

% find negative value size distributions
[neg5_r, neg5_c]     = find(PNSD_merged_5min < 0);


% remove negative value size distributions
PNSD_merged_5min(:,neg5_c)   = NaN;


Nt_merged_5min(:,neg5_c)    = NaN;


rho_merge_5min(:,neg5_c)    = NaN;

%% Check how the merged size distribution compares to measured

close all; clc

% index/indices for checking merged size distribution
idx = i;%1257, 1810, 2350, 3105, 3260, 3264

loglog(SEMS_d_mid, SEMS_PNSD_5min(:,idx), 'ok', 'MarkerFaceColor', 'k')
hold on
loglog(APS_d_mid, APS_PNSD_5min(:,idx), 'or', 'MarkerFaceColor', 'r')
loglog(SEMS_d_tail,SEMS_fit_plot(:,idx),'color','b', 'LineWidth', 3)
loglog(D_merged, PNSD_merged_5min(:,idx), '-og', 'MarkerFaceColor', 'g', 'LineWidth', 3)
% xline(SEMS_d_mid(52), 'Color', 'k');
xline(SEMS_d_tail(1), 'Color', 'k');
xline(SEMS_d_tail(end), 'Color', 'k');

% xline(APS_d_mid(1), 'Color', 'r');
% xline(APS_d_mid(12), 'Color', 'r');
hold off
ylim([1e-3 1e4])
xlim([1e-3 1e1])
legend('SEMS', ...
    'APS', ...
    'power law fit to SEMS tail')

title({datestr(time_5min(idx)) ...
    strcat('\rho = ', num2str(rho_merge_5min(idx))) ...
    strcat('fit r^{2} = ', num2str(round(stored_SEMS_fit_r2(idx),2)))})
%% added 7/11 to create timeseries of SEMS
%timeseries SEMS
SEMS_sa=NaN(1,length(time_5min));
SEMS_save=SEMS_PNSD_5min(32,:)
for i=1:length(SEMS_save);
    if isnan(SEMS_save(i));
        SEMS_sa(i)=1;
    end
end
i=1:25632;
ii=25633:51264;
iii=51265:76897;
iv=76898:102528;
%divided to 4 segments
plot(time_5min,SEMS_sa,'|','Markersize',1)
hold on
xline([time_5min(1),time_5min(end)])

datetick('x','mm/dd')


%% Saving data
clc



save_filename_5min = strcat(out_dir, 'EPCAPE_SEMS_APS_merged_5min_', datestr(now, 'yyyymmdd'), '.mat');

save(save_filename_5min, ...
    'PNSD_merged_5min', ...
    'Nt_merged_5min', ...
    'D_merged', ...
    'rho_merge_5min', ...
    'time_5min',...
    'flag' ,...
    'stored_SEMS_fit_r2',...
    'SEMS_PNSD',...
    'SEMS_d_mid')

disp('Data saved')
