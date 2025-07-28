%% Example Usage: Convert PG019 Data to NWB Format
% ================================================
%
% This script demonstrates how to use the Convert2NWB_Standalone.m
% script to convert neural data for mouse PG019 to NWB format.
%
% Prerequisites:
% - Ensure your data is organized according to the required folder structure
% - Have matnwb library installed and in MATLAB path
% - Have all helper functions available (PrepareUnits_module.m, trial_typeMaker.m, ReadMeta.m)
%
% Data Structure Expected:
% G:\G:\MiceFolders_ephys\PG019\
% ├── RECORDING\
% │   ├── ELECTROPHYSIOLOGY\
% │   │   └── [SessionDate]\
% │   │       └── [SessionName]\
% │   │           ├── SpikeTime\
% │   │           ├── EventTime\
% │   │           └── [SessionName]_t0.nidq.bin
% │   ├── BEHAVIOR\
% │   ├── ANATOMY\
% │   ├── VIDEO\
% │   └── SLIM\
% │       └── SLIM.mat
%
% ================================================

%% Clear workspace and add paths
clear all; close all; clc;

% Add matnwb to path (update this path to your matnwb installation)
addpath('C:\path\to\matnwb'); % Replace with your actual matnwb path

% Add helper functions to path (if not already in path)
addpath('.'); % Current directory should contain helper functions

%% Configuration for PG019
% ========================

% Set up parameters for PG019 conversion
params_converter = struct();

% Mouse information
params_converter.MouseNames = {'PG019'};

% Data directory (update this to your actual data path)
params_converter.directory = 'G:\G:\MiceFolders_ephys\';

% Optional parameters
params_converter.FS_RS_detection = 'automatic';
params_converter.thr_FS_RS_detection = [11, 14];

% Channel positions file path (update this to your actual path)
% This file should contain the Neuropixels channel mapping
channel_positions_file = 'D:\KILOSORTS\Kilosort-2.0\configFiles\neuropixPhase3B1_kilosortChanMap(1_130).mat';

%% Verify Data Structure
% =====================

fprintf('Verifying data structure for PG019...\n');

% Check if main directory exists
main_dir = fullfile(params_converter.directory, 'PG019');
if ~exist(main_dir, 'dir')
    error('Main directory not found: %s', main_dir);
end

% Check for required subdirectories
required_dirs = {
    fullfile(main_dir, 'RECORDING', 'ELECTROPHYSIOLOGY')
    fullfile(main_dir, 'RECORDING', 'BEHAVIOR')
    fullfile(main_dir, 'RECORDING', 'ANATOMY')
    fullfile(main_dir, 'RECORDING', 'VIDEO', 'RWA_VIDEO')
    fullfile(main_dir, 'RECORDING', 'SLIM')
};

for i = 1:length(required_dirs)
    if ~exist(required_dirs{i}, 'dir')
        error('Required directory not found: %s', required_dirs{i});
    end
end

% Check for SLIM.mat
slim_file = fullfile(main_dir, 'RECORDING', 'SLIM', 'SLIM.mat');
if ~exist(slim_file, 'file')
    error('SLIM.mat not found: %s', slim_file);
end

% Check for channel positions file
if ~exist(channel_positions_file, 'file')
    error('Channel positions file not found: %s', channel_positions_file);
end

fprintf('Data structure verification completed successfully.\n');

%% List Available Sessions
% =======================

fprintf('\nListing available sessions for PG019...\n');

ephys_dir = fullfile(main_dir, 'RECORDING', 'ELECTROPHYSIOLOGY');
session_dates = dir(ephys_dir);
session_dates = session_dates(3:end); % Remove . and ..

fprintf('Found %d session dates:\n', length(session_dates));
for i = 1:length(session_dates)
    fprintf('  %s\n', session_dates(i).name);
    
    % List sessions within each date
    date_dir = fullfile(ephys_dir, session_dates(i).name);
    sessions = dir(date_dir);
    sessions = sessions(3:end);
    
    for j = 1:length(sessions)
        fprintf('    - %s\n', sessions(j).name);
    end
end

%% Run Conversion for Specific Session (Optional)
% =============================================

% If you want to convert only a specific session, uncomment and modify this section
% specific_date = '20231213'; % Replace with actual date
% specific_session = 'PG019_20231213_g0'; % Replace with actual session name
% 
% fprintf('\nConverting specific session: %s/%s\n', specific_date, specific_session);
% 
% % Verify specific session exists
% session_dir = fullfile(ephys_dir, specific_date, specific_session);
% if ~exist(session_dir, 'dir')
%     error('Session directory not found: %s', session_dir);
% end
% 
% % Check for required files in this session
% required_files = {
%     fullfile(session_dir, 'SpikeTime')
%     fullfile(session_dir, 'EventTime', 'Behavior_data.txt')
%     fullfile(session_dir, 'EventTime', 'Camera_TTL.txt')
%     fullfile(session_dir, 'EventTime', 'Camera_Arm.txt')
%     fullfile(session_dir, 'EventTime', 'Laser_Light.txt')
%     fullfile(session_dir, [specific_session '_t0.nidq.bin'])
% };
% 
% for i = 1:length(required_files)
%     if ~exist(required_files{i}, 'file') && ~exist(required_files{i}, 'dir')
%         fprintf('Warning: Required file/directory not found: %s\n', required_files{i});
%     end
% end

%% Run Full Conversion
% ===================

fprintf('\nStarting NWB conversion for PG019...\n');

try
    % Call the main conversion function
    convert_to_nwb(params_converter);
    
    fprintf('\nConversion completed successfully!\n');
    
    % List output files
    output_dir = fullfile(params_converter.directory, 'PG019-nwb');
    if exist(output_dir, 'dir')
        fprintf('\nGenerated NWB files:\n');
        output_files = dir(fullfile(output_dir, '**/*.nwb'));
        for i = 1:length(output_files)
            fprintf('  %s\n', fullfile(output_files(i).folder, output_files(i).name));
        end
    end
    
catch ME
    fprintf('\nError during conversion: %s\n', ME.message);
    fprintf('Error details:\n');
    disp(getReport(ME, 'extended'));
end

%% Verify Output Files
% ===================

fprintf('\nVerifying output files...\n');

output_dir = fullfile(params_converter.directory, 'PG019-nwb');
if exist(output_dir, 'dir')
    nwb_files = dir(fullfile(output_dir, '**/*.nwb'));
    fprintf('Found %d NWB files:\n', length(nwb_files));
    
    for i = 1:length(nwb_files)
        file_path = fullfile(nwb_files(i).folder, nwb_files(i).name);
        file_info = dir(file_path);
        fprintf('  %s (%.2f MB)\n', nwb_files(i).name, file_info.bytes/1024/1024);
    end
else
    fprintf('No output directory found: %s\n', output_dir);
end

%% Test NWB File Reading (Optional)
% ================================

% Uncomment this section to test reading the generated NWB files
% fprintf('\nTesting NWB file reading...\n');
% 
% if exist(output_dir, 'dir')
%     nwb_files = dir(fullfile(output_dir, '**/*.nwb'));
%     if ~isempty(nwb_files)
%         test_file = fullfile(nwb_files(1).folder, nwb_files(1).name);
%         try
%             nwb = nwbRead(test_file);
%             fprintf('Successfully read NWB file: %s\n', nwb_files(1).name);
%             
%             % Display basic information
%             fprintf('Session identifier: %s\n', nwb.identifier);
%             fprintf('Session description: %s\n', nwb.session_description);
%             
%             % Check for units
%             if isprop(nwb, 'units') && ~isempty(nwb.units)
%                 fprintf('Number of units: %d\n', height(nwb.units));
%             end
%             
%             % Check for trials
%             if isprop(nwb, 'intervals_trials') && ~isempty(nwb.intervals_trials)
%                 fprintf('Number of trials: %d\n', height(nwb.intervals_trials));
%             end
%             
%         catch ME
%             fprintf('Error reading NWB file: %s\n', ME.message);
%         end
%     end
% end

fprintf('\nExample usage completed.\n'); 