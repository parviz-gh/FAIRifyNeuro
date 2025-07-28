%% ============================================================================
% CONVERT2NWB_STANDALONE
% ============================================================================
% 
% This script converts neural data from the post-processing pipeline format
% to NWB (Neurodata Without Borders) format.
%
% DATA STRUCTURE REQUIREMENTS:
% ===========================
% 
% Your data should be organized in the following folder structure:
% 
% MouseFolder/
% ├── RECORDING/
% │   ├── ELECTROPHYSIOLOGY/
% │   │   └── SessionDate/
% │   │       └── SessionName/
% │   │           ├── SpikeTime/
% │   │           │   └── BrainArea/
% │   │           │       └── Spikes.mat
% │   │           ├── EventTime/
% │   │           │   ├── Behavior_data.txt
% │   │           │   ├── Camera_TTL.txt
% │   │           │   ├── Camera_Arm.txt
% │   │           │   └── Laser_Light.txt
% │   │           └── SessionName_t0.nidq.bin
% │   ├── BEHAVIOR/
% │   │   └── SessionDate/
% │   │       └── SessionName/
% │   │           ├── Results.txt
% │   │           ├── behavioralstruct.mat
% │   │           └── mouse_info.xlsx
% │   ├── ANATOMY/
% │   │   └── SessionDate/
% │   │       └── SessionName/
% │   │           └── ProbeName/
% │   │               └── ANATOMY.mat
% │   └── VIDEO/
% │       └── RWA_VIDEO/
% │           └── SessionDate/
% │               └── SessionName/
% │                   └── DlcOut/
% │                       ├── Video_info.mat
% │                       └── poses.mat
% └── RECORDING/
%     └── SLIM/
%         └── SLIM.mat
%
% REQUIRED DATA FILES:
% ====================
%
% 1. Spikes.mat - Contains spike data with fields:
%    - times: spike times for each unit
%    - cluster: cluster IDs from Kilosort
%    - channel: channel numbers
%    - Shape: waveform shapes
%    - RsUnits: regular spiking units
%    - FsUnits: fast spiking units
%    - Width: spike widths
%    - Amplitude: spike amplitudes
%    - Ypos: Y positions
%    - Probe_name: probe names
%    - firingRate: firing rates
%    - spikeCount: spike counts
%    - QualityMatrix: quality metrics
%    - cluster_XYZ_allen: Allen CCF coordinates
%    - cluster_fullarea_allen: Allen CCF area names
%    - cluster_depth_allen: depths in Allen CCF
%    - cluster_area_targeted: targeted brain areas
%
% 2. ANATOMY.mat - Contains anatomical data with fields:
%    - channel_probe_name: probe names for each channel
%    - channel_area_targeted: targeted brain areas
%    - channel_XYZ_allen: Allen CCF coordinates for channels
%    - channel_area_allen: Allen CCF area names for channels
%    - channel_fullarea_allen: Full Allen CCF area names
%    - channel_goodchannelMap: good channel mapping
%
% 3. behavioralstruct.mat - Contains behavioral data with fields:
%    - behavior_event: table with trial information
%
% 4. Results.txt - Behavioral results file
%
% 5. mouse_info.xlsx - Mouse metadata with columns:
%    - age: mouse age
%    - date fo birth: date of birth
%    - starin: mouse strain
%    - sex: mouse sex
%
% 6. Behavior_data.txt - Behavioral time series data
%
% 7. Video_info.mat - Video metadata
%
% 8. poses.mat - DeepLabCut pose data with fields:
%    - jawcord: jaw coordinates
%    - tonguecord: tongue coordinates
%    - Whisk_skel_angle: whisker angles
%    - snouta_snoutp_angle: snout angles
%    - Camera_TTL_edgeTime: video timestamps
%
% 9. SLIM.mat - Contains probe information mapping
%
% OUTPUT:
% =======
% Creates an NWB file with the following structure:
% - General metadata (subject info, session info)
% - Trial information
% - Behavioral time series (jaw, tongue, whisker, snout coordinates)
% - Behavioral events (valve opening times)
% - Electrophysiology data (spike times, waveforms, electrode info)
% - Quality metrics and unit classifications
%
% DEPENDENCIES:
% =============
% - matnwb library (https://github.com/NeurodataWithoutBorders/matnwb)
% - Helper functions: PrepareUnits_module.m, trial_typeMaker.m, ReadMeta.m
%
% USAGE:
% ======
% 1. Set the parameters below
% 2. Ensure all required data files are in the correct folder structure
% 3. Run this script
%
% AUTHOR: Parviz Ghaderi
% DATE: 2024
% ============================================================================

%% Configuration Parameters
% ========================

% Mouse information
params_converter.MouseNames = {'PG019'}; % Add your mouse names here
params_converter.directory = 'G:\G:\MiceFolders_ephys\'; % Set your data directory

% Optional parameters
params_converter.FS_RS_detection = 'automatic'; % 'automatic' or 'manual'
params_converter.thr_FS_RS_detection = [11, 14]; % Thresholds for FS/RS detection

% Add matnwb to path (adjust path as needed)
addpath('path/to/matnwb'); % Replace with your matnwb path

%% Main Conversion Function
% ========================

function convert_to_nwb(params_converter)
    
    fprintf('Starting NWB conversion...\n');
    tic;
    
    for MouseName = 1:length(params_converter.MouseNames)
        curr_mouse_name = cell2mat(params_converter.MouseNames(MouseName));
        CurrMouseNameCode = curr_mouse_name(3:end);
        
        fprintf('Processing mouse: %s\n', curr_mouse_name);
        
        % Load SLIM data (probe information)
        slim_file = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'SLIM', 'SLIM.mat');
        if ~exist(slim_file, 'file')
            error('SLIM.mat not found for mouse %s', curr_mouse_name);
        end
        load(slim_file);
        
        % Get session dates
        ephys_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'ELECTROPHYSIOLOGY');
        DateNames = dir(ephys_dir);
        DateNames = DateNames(3:end); % Remove . and ..
        
        for DateName = 1:length(DateNames)
            CurrDateName = DateNames(DateName).name;
            fprintf('  Processing session: %s\n', CurrDateName);
            
            % Get session names (g_names)
            session_dir = fullfile(ephys_dir, CurrDateName);
            g_names = dir(session_dir);
            g_names = g_names(3:end);
            
            SessionCounter = 0;
            for ind_g = 1:length(g_names)
                curr_g_name = g_names(ind_g).name;
                SessionCounter = SessionCounter + 1;
                
                fprintf('    Processing session: %s\n', curr_g_name);
                
                % Define all required directories
                spike_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'ELECTROPHYSIOLOGY', CurrDateName, curr_g_name, 'SpikeTime');
                event_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'ELECTROPHYSIOLOGY', CurrDateName, curr_g_name, 'EventTime');
                beh_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'BEHAVIOR', CurrDateName, curr_g_name);
                nidaq_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'ELECTROPHYSIOLOGY', CurrDateName, curr_g_name);
                anatomy_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'ANATOMY', CurrDateName, curr_g_name);
                video_dir = fullfile(params_converter.directory, curr_mouse_name, 'RECORDING', 'VIDEO', 'RWA_VIDEO', CurrDateName, curr_g_name, 'DlcOut');
                
                % Load behavioral data
                try
                    OriginalBehavior = importdata(fullfile(beh_dir, 'Results.txt'));
                    Behavior = importdata(fullfile(event_dir, 'Behavior_data.txt'));
                    Behavior = Behavior.data;
                    metafile = importdata(fullfile(beh_dir, 'mouse_info.xlsx'));
                    
                    % Load behavioral structure
                    load(fullfile(beh_dir, 'behavioralstruct.mat'));
                    
                    % Load event data
                    load(fullfile(event_dir, 'Camera_TTL.txt'));
                    load(fullfile(event_dir, 'Camera_Arm.txt'));
                    load(fullfile(event_dir, 'Laser_Light.txt'));
                    
                    % Load video data
                    load(fullfile(video_dir, 'Video_info.mat'));
                    load(fullfile(video_dir, 'poses.mat'));
                    
                catch ME
                    fprintf('Error loading data for session %s: %s\n', curr_g_name, ME.message);
                    continue;
                end
                
                % Create NWB file
                try
                    nwb = create_nwb_file(curr_mouse_name, curr_g_name, nidaq_dir, metafile);
                    
                    % Add subject information
                    nwb = add_subject_info(nwb, curr_mouse_name, metafile);
                    
                    % Add trial information
                    nwb = add_trial_info(nwb, behavior_event);
                    
                    % Add behavioral data
                    nwb = add_behavioral_data(nwb, Behavior_Timeseries, poses);
                    
                    % Add electrophysiology data
                    nwb = add_ephys_data(nwb, spike_dir, anatomy_dir, SLIM, curr_g_name);
                    
                    % Save NWB file
                    save_nwb_file(nwb, params_converter.directory, curr_mouse_name, CurrDateName, curr_g_name);
                    
                    fprintf('    Successfully created NWB file for session: %s\n', curr_g_name);
                    
                catch ME
                    fprintf('Error creating NWB file for session %s: %s\n', curr_g_name, ME.message);
                    continue;
                end
                
                clear nwb;
            end
        end
    end
    
    fprintf('NWB conversion completed in %.2f seconds\n', toc);
end

%% Helper Functions
% ================

function nwb = create_nwb_file(curr_mouse_name, curr_g_name, nidaq_dir, metafile)
    % Create the main NWB file structure
    
    % Read metadata to get session start time
    [meta_nidaq] = ReadMeta([curr_g_name '_t0.nidq.bin'], nidaq_dir);
    session_start_time = datetime(meta_nidaq.fileCreateTime, 'TimeZone', 'local', 'InputFormat', 'uuuu-MM-dd''T''HH:mm:ss', 'Format', 'uuuu-MM-dd''T''HH:mm:ss Z');
    
    % Create unique identifier
    session = meta_nidaq.fileCreateTime;
    session(regexp(session, '-')) = [];
    session(regexp(session, ':')) = [];
    identifier = ['sub-' curr_mouse_name '_ses-' session];
    
    % Create NWB file
    nwb = NwbFile( ...
        'session_description', 'Neuropixels recording in context-dependent whisker detection task', ...
        'identifier', identifier, ...
        'session_start_time', session_start_time, ...
        'general_experiment_description', 'Context-dependent whisker detection task with optogenetics', ...
        'general_experimenter', 'Ghaderi, Parviz', ...
        'general_lab', 'LSENS', ...
        'general_keywords', {'Neuropixels', 'Neocortex'}, ...
        'general_session_id', identifier, ...
        'general_institution', 'Brain Mind Institute, EPFL', ...
        'general_stimulus', {'pure tone', 'whisker stimulus'}, ...
        'general_surgery', 'Implant head-post and craniotomy');
end

function nwb = add_subject_info(nwb, curr_mouse_name, metafile)
    % Add subject information to NWB file
    
    % Extract metadata
    age = cell2mat(metafile.textdata(2, strcmp(metafile.textdata(1, :), 'age')));
    data_of_birth = strrep(cell2mat(metafile.textdata(2, strcmp(metafile.textdata(1, :), 'date fo birth'))), '/', '-');
    data_of_birth = strrep(data_of_birth, '.', '-');
    DOB = datetime(data_of_birth, 'InputFormat', 'dd-MM-yyyy', 'Format', 'uuuu-MM-dd''T''HH:mm:ss');
    strain = cell2mat(metafile.textdata(2, strcmp(metafile.textdata(1, :), 'starin')));
    species = 'Mus musculus';
    sex = cell2mat(metafile.textdata(2, strcmp(metafile.textdata(1, :), 'sex')));
    sex = upper(sex);
    weight = num2str(metafile.data);
    description = 'task, training, surgery, ...';
    
    % Create subject object
    subject = types.core.Subject( ...
        'subject_id', curr_mouse_name, ...
        'date_of_birth', DOB, ...
        'age', age, ...
        'description', description, ...
        'species', species, ...
        'genotype', strain, ...
        'sex', sex, ...
        'weight', weight);
    
    nwb.general_subject = subject;
end

function nwb = add_trial_info(nwb, behavior_event)
    % Add trial information to NWB file
    
    % Add trial_type if missing
    if ~any(strcmp('trial_type', behavior_event.Properties.VariableNames))
        trial_type = trial_typeMaker(behavior_event.whiskerstim, behavior_event.sound)';
        trial_type = table(trial_type);
        behavior_event = [behavior_event, trial_type];
    end
    
    % Create trials table
    trials = types.core.TimeIntervals( ...
        'colnames', {'start_time', 'stop_time', ...
        'context', 'auditory_stim_frequency', 'auditory_stim_amplitude', 'auditory_stim_time', 'auditory_stim_duration', ...
        'whisker_stim', 'whisker_stim_amplitude', 'whisker_stim_time', 'whisker_stim_duration', ...
        'opto_stim', 'opto_stim_frequency', 'opto_stim_amplitude', 'opto_stim_start_time', 'opto_stim_stop_time', ...
        'lick_flag', 'lick_time', 'early_lick', 'trial_type'}, ...
        'description', 'trial data and properties', ...
        'id', types.hdmf_common.ElementIdentifiers('data', 0:numel(behavior_event.start_time) - 1), ...
        'start_time', types.hdmf_common.VectorData('data', behavior_event.start_time, 'description', 'Start time of trial'), ...
        'stop_time', types.hdmf_common.VectorData('data', behavior_event.stop_time, 'description', 'End of each trial'), ...
        'context', types.hdmf_common.VectorData('data', behavior_event.sound, 'description', 'Boolean for sound'), ...
        'auditory_stim_frequency', types.hdmf_common.VectorData('data', behavior_event.sound_frequency, 'description', 'Sound frequency in Hz'), ...
        'auditory_stim_amplitude', types.hdmf_common.VectorData('data', behavior_event.sound_amplitude, 'description', 'Sound amplitude in dB'), ...
        'auditory_stim_time', types.hdmf_common.VectorData('data', behavior_event.sound_starttime, 'description', 'Sound start time in s'), ...
        'auditory_stim_duration', types.hdmf_common.VectorData('data', behavior_event.sound_duration, 'description', 'Sound duration in s'), ...
        'whisker_stim', types.hdmf_common.VectorData('data', logical(behavior_event.whiskerstim), 'description', 'Boolean for whisker stim'), ...
        'whisker_stim_amplitude', types.hdmf_common.VectorData('data', behavior_event.whiskerstim_amplitude, 'description', 'Whisker stim amplitude in V'), ...
        'whisker_stim_time', types.hdmf_common.VectorData('data', behavior_event.whiskerstim_starttime, 'description', 'Whisker stim start time in s'), ...
        'whisker_stim_duration', types.hdmf_common.VectorData('data', behavior_event.whiskerstim_duration, 'description', 'Whisker stim duration in s'), ...
        'opto_stim', types.hdmf_common.VectorData('data', logical(behavior_event.optogenetics), 'description', 'Boolean for optogenetics'), ...
        'opto_stim_frequency', types.hdmf_common.VectorData('data', behavior_event.opto_frequency, 'description', 'Pulse train frequency in Hz'), ...
        'opto_stim_amplitude', types.hdmf_common.VectorData('data', behavior_event.opto_power, 'description', 'Laser power in mW'), ...
        'opto_stim_start_time', types.hdmf_common.VectorData('data', behavior_event.opto_starttime, 'description', 'Pulse duration in s'), ...
        'opto_stim_stop_time', types.hdmf_common.VectorData('data', behavior_event.opto_endtime, 'description', 'Individual pulse timestamps'), ...
        'lick_flag', types.hdmf_common.VectorData('data', logical(behavior_event.response), 'description', 'Boolean for licking'), ...
        'lick_time', types.hdmf_common.VectorData('data', behavior_event.response_time - 1.5, 'description', 'First lick time in s'), ...
        'early_lick', types.hdmf_common.VectorData('data', ~logical(behavior_event.completed_trial), 'description', 'Boolean for completed / aborted trial'), ...
        'trial_type', types.hdmf_common.VectorData('data', behavior_event.trial_type, 'description', 'Trial type 1: gotone_whisker 2: gotone_nowhisker 3: nogotone_whisker 4: nogotone_nowhisker 5: notone_whisker'));
    
    nwb.intervals_trials = trials;
end

function nwb = add_behavioral_data(nwb, Behavior_Timeseries, poses)
    % Add behavioral time series data to NWB file
    
    % Lick piezo
    LickPiezo = Behavior_Timeseries.tosave_Piezo_Lick_signal;
    time_piezo = [1:1:length(LickPiezo)] ./ Behavior_Timeseries.samplinRate;
    LickPiezo_comp = types.untyped.DataPipe('data', LickPiezo);
    
    Piezo_lick_trace = types.core.TimeSeries( ...
        'data', LickPiezo_comp', ...
        'data_unit', 'Volt', ...
        'timestamps', time_piezo, ...
        'timestamps_unit', 's', ...
        'description', 'Lick trace recorded using piezo sensor');
    
    % Jaw coordinate
    JawCoordinate = cell2mat(poses.jawcord);
    ts_video = cell2mat(poses.Camera_TTL_edgeTime);
    ts_video_comp = types.untyped.DataPipe('data', ts_video);
    dlc_timestamps = ts_video;
    
    Jaw_Coordinate = types.core.TimeSeries( ...
        'data', JawCoordinate', ...
        'data_unit', 'pixel', ...
        'timestamps', dlc_timestamps, ...
        'timestamps_unit', 's', ...
        'description', 'Jaw coordinate from DLC');
    
    % Tongue coordinate
    TongueCoordinate = cell2mat(poses.tonguecord);
    Tongue_Coordinate = types.core.TimeSeries( ...
        'data', TongueCoordinate', ...
        'data_unit', 'pixel', ...
        'timestamps', dlc_timestamps, ...
        'timestamps_unit', 's', ...
        'description', 'Tongue coordinate from DLC');
    
    % Whisker angle
    whiskerangle = cell2mat(poses.Whisk_skel_angle);
    C2Whisker_Angle = types.core.TimeSeries( ...
        'data', whiskerangle, ...
        'data_unit', 'degrees', ...
        'timestamps', dlc_timestamps, ...
        'timestamps_unit', 's', ...
        'description', 'Whisker angle from DLC');
    
    % Snout angle
    SnoutAPangle = cell2mat(poses.snouta_snoutp_angle);
    Snout_Angle = types.core.TimeSeries( ...
        'data', SnoutAPangle, ...
        'data_unit', 'degrees', ...
        'timestamps', dlc_timestamps, ...
        'timestamps_unit', 's', ...
        'description', 'Snout left/right angle from DLC');
    
    % Create behavioral time series module
    BehavioralTimeSeries = types.core.BehavioralTimeSeries(...
        'Jaw_Coordinate', Jaw_Coordinate, ...
        'Tongue_Coordinate', Tongue_Coordinate, ...
        'C2Whisker_Angle', C2Whisker_Angle, ...
        'Snout_Angle', Snout_Angle, ...
        'Piezo_lick_trace', Piezo_lick_trace);
    
    % Create processing module
    Behavior = types.core.ProcessingModule('description', 'Behavioral data');
    Behavior.nwbdatainterface.set('BehavioralTimeSeries', BehavioralTimeSeries);
    
    % Add behavioral events
    Valve_OpeningTime = types.core.TimeSeries( ...
        'data', 5 * ones(length(Behavior_Timeseries.valveopenning_time), 1), ...
        'data_unit', 'Volt', ...
        'timestamps', Behavior_Timeseries.valveopenning_time, ...
        'timestamps_unit', 's', ...
        'description', 'Valve opening time');
    
    BehavioralEvents = types.core.BehavioralEvents(...
        'Valve_OpeningTime', Valve_OpeningTime);
    
    Behavior.nwbdatainterface.set('BehavioralEvents', BehavioralEvents);
    nwb.processing.set('behavior', Behavior);
end

function nwb = add_ephys_data(nwb, spike_dir, anatomy_dir, SLIM, curr_g_name)
    % Add electrophysiology data to NWB file
    
    % Get probe names
    ProbNames = dir(fullfile(anatomy_dir, '*imec*'));
    counter = 0;
    tblall = [];
    ConcatSpiks = [];
    
    for iProbe = 1:length(ProbNames)
        counter = counter + 1;
        curr_prob_file_name = ProbNames(iProbe).name;
        [~, ind] = ismember(curr_prob_file_name, SLIM(:, 1));
        curr_prb_name = curr_prob_file_name(end - 4:end);
        curr_area = cell2mat(SLIM(ind, 3));
        
        % Load spike data
        spike_file = fullfile(spike_dir, curr_area, 'Spikes.mat');
        if ~exist(spike_file, 'file')
            fprintf('Warning: Spikes.mat not found for area %s\n', curr_area);
            continue;
        end
        load(spike_file);
        
        % Load anatomy data
        anatomy_file = fullfile(anatomy_dir, curr_prob_file_name, 'ANATOMY.mat');
        if ~exist(anatomy_file, 'file')
            fprintf('Warning: ANATOMY.mat not found for probe %s\n', curr_prob_file_name);
            continue;
        end
        load(anatomy_file);
        
        % Add anatomy information to spikes
        Spikes.cluster_XYZ_allen = ANATOMY.cluster_XYZ_allen;
        Spikes.cluster_area_allen = ANATOMY.cluster_area_allen;
        Spikes.cluster_fullarea_allen = ANATOMY.cluster_fullarea_allen;
        Spikes.cluster_depth_allen = ANATOMY.cluster_depth_allen;
        Spikes.cluster_area_targeted = ANATOMY.cluster_area_targeted;
        ConcatSpiks = [ConcatSpiks; Spikes];
        
        % Create electrode table
        variables = {'ccf_ap', 'ccf_dv', 'ccf_ml', 'rel_x', 'rel_y', 'shank', 'ccf_location', 'ccf_full_location', 'location', 'group', 'group_name', 'channel_name', 'good_channel'};
        tbl = cell2table(cell(0, length(variables)), 'VariableNames', variables);
        
        % Create device
        device = types.core.Device(...
            'description', 'Neuropixels 3B2', ...
            'manufacturer', 'imec');
        
        nwb.general_devices.set(cell2mat(ANATOMY.channel_probe_name(1)), device);
        
        % Create electrode group
        electrode_group = types.core.ElectrodeGroup( ...
            'description', ['Electrode group for ' cell2mat(ANATOMY.channel_probe_name(1))], ...
            'location', cell2mat(ANATOMY.channel_area_targeted(1)), ...
            'device', types.untyped.SoftLink(device));
        
        nwb.general_extracellular_ephys.set([cell2mat(ANATOMY.channel_probe_name(1))], electrode_group);
        group_object_view = types.untyped.ObjectView(electrode_group);
        
        % Load channel positions
        channel_positions_file = 'D:\KILOSORTS\Kilosort-2.0\configFiles\neuropixPhase3B1_kilosortChanMap(1_130).mat';
        if ~exist(channel_positions_file, 'file')
            error('Channel positions file not found: %s', channel_positions_file);
        end
        channel_positions_AllsavedChannel = load(channel_positions_file);
        probe_rel_x = channel_positions_AllsavedChannel.xcoords;
        probe_rel_y = channel_positions_AllsavedChannel.ycoords;
        shank = channel_positions_AllsavedChannel.shankInd;
        nchannels_per_probe_saved = length(shank);
        ch_id = channel_positions_AllsavedChannel.chanMap0ind;
        
        % Create electrode table entries
        for ielec = 1:nchannels_per_probe_saved
            ch_name = ielec - 1;
            if ismember(ch_name, ANATOMY.channel_goodchannelMap.channel_id)
                good_channel = 1;
            else
                good_channel = 0;
            end
            
            tbl = [tbl; ...
                {ANATOMY.channel_XYZ_allen(ielec, 1), ... 'ccf_ap'
                ANATOMY.channel_XYZ_allen(ielec, 2), ... 'ccf_dv'
                ANATOMY.channel_XYZ_allen(ielec, 3), ... 'ccf_ml'
                probe_rel_x(ielec), ... 'rel_x'
                probe_rel_y(ielec), ... 'rel_y'
                shank(ielec), ... 'shank'
                cell2mat(ANATOMY.channel_area_allen(ielec, 1)), ... 'ccf_location'
                cell2mat(ANATOMY.channel_fullarea_allen(ielec, 1)), ... 'ccf_full_location'
                cell2mat(ANATOMY.channel_area_targeted(ielec, 1)), ... 'location'
                group_object_view, ... 'group'
                [cell2mat(ANATOMY.channel_probe_name(ielec, 1)) '_shank' num2str(shank(ielec))], ... 'group_name'
                ch_id(ielec), ... 'channel_name'
                good_channel}]; % 'good_channel'
        end
        
        tblall = [tblall; tbl];
    end
    
    % Create final electrode table
    StructDescription = {'ccf_ap', 'ccf_dv', 'ccf_ml', 'rel_x', 'rel_y', 'shank', 'ccf_location', 'ccf_full_location', 'location', 'group', 'group_name', 'channel_name', 'good_channel'};
    mytable = types.hdmf_common.DynamicTable(...
        'description', 'A table of all electrodes (i.e. channels) used for recording.', ...
        'colnames', StructDescription, ...
        'id', types.hdmf_common.ElementIdentifiers('data', int64(0:size(tblall, 1) - 1)), ...
        'ccf_ap', types.hdmf_common.VectorData('data', tblall.ccf_ap, 'description', 'The AP coordinate (Allen CCF) of the channel location'), ...
        'ccf_dv', types.hdmf_common.VectorData('data', tblall.ccf_dv, 'description', 'The DV coordinate (Allen CCF) of the channel location'), ...
        'ccf_ml', types.hdmf_common.VectorData('data', tblall.ccf_ml, 'description', 'The ML coordinate (Allen CCF) of the channel location'), ...
        'ccf_location', types.hdmf_common.VectorData('data', tblall.ccf_location, 'description', 'Brain region (annotation based on Allen CCF)'), ...
        'ccf_full_location', types.hdmf_common.VectorData('data', tblall.ccf_full_location, 'description', 'Brain region (annotation based on Allen CCF)'), ...
        'location', types.hdmf_common.VectorData('data', tblall.location, 'description', 'The location of the targeted brain region'), ...
        'rel_x', types.hdmf_common.VectorData('data', tblall.rel_x, 'description', 'X coordinate of channel relative to the shank'), ...
        'rel_y', types.hdmf_common.VectorData('data', tblall.rel_y, 'description', 'Y coordinate of channel relative to the shank'), ...
        'shank', types.hdmf_common.VectorData('data', tblall.shank, 'description', 'Shank number'), ...
        'group', types.hdmf_common.VectorData('data', tblall.group, 'description', 'Electrode group name'), ...
        'group_name', types.hdmf_common.VectorData('data', tblall.group_name, 'description', 'Soft link to electrode group'), ...
        'channel_name', types.hdmf_common.VectorData('data', tblall.channel_name, 'description', 'Shank channel number'), ...
        'good_channel', types.hdmf_common.VectorData('data', logical(tblall.good_channel), 'description', 'Label of channel based on Kilosort: bad channel=0, good channel=1)'));
    
    nwb.general_extracellular_ephys_electrodes = mytable;
    
    % Prepare units data
    if ~isempty(ConcatSpiks)
        fnames = fieldnames(ConcatSpiks);
        Spokes = [];
        for f = 1:length(fnames)
            currfname = cell2mat(fnames(f));
            eval(['Spokes.' currfname '=vertcat(ConcatSpiks(:).' currfname ')']);
        end
        
        Units_struct = PrepareUnits_module(Spokes);
        
        % Create units table
        spikeTimes = Spokes.times';
        [spike_times_vector, spike_times_index] = util.create_indexed_column(spikeTimes, 'spike times');
        
        % Waveforms
        waveform_mean = types.hdmf_common.VectorData('data', Units_struct.mean_waveform', 'description', 'mean of waveform');
        
        % Electrodes
        electrodes_object_view = types.untyped.ObjectView('/general/extracellular_ephys/electrodes');
        [electrodes, electrodes_index] = util.create_indexed_column(num2cell(Spokes.channel'), '/units/electrodes');
        
        % Quality check matrix
        qualit_matrix = (Units_struct.quality_table{:,:});
        QCmat = types.hdmf_common.VectorData('data', qualit_matrix(:, 1:23)', 'description', ' qc matrix ');
        
        % Create units table
        nwb.units = types.core.Units( ...
            'colnames', {'spike_times', 'electrodes', 'waveform_raw', ...
            'ccf_xyz', 'ccf_location', 'ccf_depth', 'rsUnits', 'fsUnits', 'spike_width', 'spike_amplitude', 'rel_y', ...
            'probe_name', 'location', 'firing_rate', 'spike_count', 'allenccf_area_layer', 'cluster_id'}, ...
            'description', 'units table', ...
            'id', types.hdmf_common.ElementIdentifiers('data', int64(0:length(spikeTimes) - 1)), ...
            'spike_times', spike_times_vector, ...
            'spike_times_index', spike_times_index, ...
            'electrodes', types.hdmf_common.DynamicTableRegion('table', electrodes_object_view, 'description', 'Main channel', 'data', electrodes.data), ...
            'waveform_raw', waveform_mean, ...
            'ccf_xyz', types.hdmf_common.VectorData('data', Units_struct.ccf_XYZ', 'description', 'Unit coordinate, based on Allen CCF in [ap,dv,ml]'), ...
            'ccf_location', types.hdmf_common.VectorData('data', [Units_struct.ccf_area], 'description', 'Unit location, annotated based on Allen CCF'), ...
            'ccf_depth', types.hdmf_common.VectorData('data', Units_struct.ccf_depth, 'description', 'Unit depth from surface of brain in um'), ...
            'rsUnits', types.hdmf_common.VectorData('data', Units_struct.rsUnits, 'description', 'Regular spiking units index based on spike width'), ...
            'fsUnits', types.hdmf_common.VectorData('data', Units_struct.fsUnits, 'description', 'Fast spiking units index based on spike width'), ...
            'spike_width', types.hdmf_common.VectorData('data', Units_struct.trough_to_peak, 'description', 'Trough to peak in ms'), ...
            'spike_amplitude', types.hdmf_common.VectorData('data', Units_struct.amplitude, 'description', 'Spike amplitude in uV'), ...
            'rel_y', types.hdmf_common.VectorData('data', Units_struct.rel_y, 'description', 'Relative y position of unit on the recorded shank'), ...
            'probe_name', types.hdmf_common.VectorData('data', Units_struct.probe_name, 'description', 'Name of probe for recorded unit'), ...
            'location', types.hdmf_common.VectorData('data', Units_struct.targeted_area, 'description', 'Location (identified) of unit'), ...
            'firing_rate', types.hdmf_common.VectorData('data', Units_struct.firing_rate, 'description', 'Firing rate of recorded unit in Hz'), ...
            'spike_count', types.hdmf_common.VectorData('data', Units_struct.spike_count, 'description', 'Number of spikes in recording session for each unit'), ...
            'allenccf_area_layer', types.hdmf_common.VectorData('data', Units_struct.allenccf_area_layer, 'description', 'Cortical layer of each unit based on Allen CCF'), ...
            'cluster_id', types.hdmf_common.VectorData('data', Units_struct.cluster, 'description', 'Cluster id given by Kilosort'));
    end
end

function save_nwb_file(nwb, directory, curr_mouse_name, CurrDateName, curr_g_name)
    % Save the NWB file
    
    % Create output directory
    output_dir = fullfile(directory, [curr_mouse_name '-nwb'], CurrDateName, curr_g_name);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Create filename
    identifier = nwb.identifier;
    output_file = fullfile(output_dir, [identifier '-processed-behavior.nwb']);
    
    % Remove existing file if it exists
    if exist(output_file, 'file')
        delete(output_file);
    end
    
    % Export NWB file
    nwbExport(nwb, output_file);
    fprintf('Saved NWB file: %s\n', output_file);
end

%% Run the conversion
% ==================

% Call the main conversion function
convert_to_nwb(params_converter); 