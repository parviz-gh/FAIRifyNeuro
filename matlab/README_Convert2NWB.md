# Convert2NWB - Neural Data to NWB Format Converter

This repository contains a MATLAB script to convert neural data from the post-processing pipeline format to NWB (Neurodata Without Borders) format.

## Overview

The `Convert2NWB_Standalone.m` script extracts the NWB conversion functionality from the main post-processing pipeline and provides a standalone solution for converting your neural data to the standardized NWB format.

## Data Structure Requirements

Your data must be organized in the following folder structure:

```
MouseFolder/
├── RECORDING/
│   ├── ELECTROPHYSIOLOGY/
│   │   └── SessionDate/
│   │       └── SessionName/
│   │           ├── SpikeTime/
│   │           │   └── BrainArea/
│   │           │       └── Spikes.mat
│   │           ├── EventTime/
│   │           │   ├── Behavior_data.txt
│   │           │   ├── Camera_TTL.txt
│   │           │   ├── Camera_Arm.txt
│   │           │   └── Laser_Light.txt
│   │           └── SessionName_t0.nidq.bin
│   ├── BEHAVIOR/
│   │   └── SessionDate/
│   │       └── SessionName/
│   │           ├── Results.txt
│   │           ├── behavioralstruct.mat
│   │           └── mouse_info.xlsx
│   ├── ANATOMY/
│   │   └── SessionDate/
│   │       └── SessionName/
│   │           └── ProbeName/
│   │               └── ANATOMY.mat
│   └── VIDEO/
│       └── RWA_VIDEO/
│           └── SessionDate/
│               └── SessionName/
│                   └── DlcOut/
│                       ├── Video_info.mat
│                       └── poses.mat
└── RECORDING/
    └── SLIM/
        └── SLIM.mat
```

## Required Data Files

### 1. Spikes.mat
Contains spike data with the following fields:
- `times`: spike times for each unit
- `cluster`: cluster IDs from Kilosort
- `channel`: channel numbers
- `Shape`: waveform shapes
- `RsUnits`: regular spiking units
- `FsUnits`: fast spiking units
- `Width`: spike widths
- `Amplitude`: spike amplitudes
- `Ypos`: Y positions
- `Probe_name`: probe names
- `firingRate`: firing rates
- `spikeCount`: spike counts
- `QualityMatrix`: quality metrics
- `cluster_XYZ_allen`: Allen CCF coordinates
- `cluster_fullarea_allen`: Allen CCF area names
- `cluster_depth_allen`: depths in Allen CCF
- `cluster_area_targeted`: targeted brain areas

### 2. ANATOMY.mat
Contains anatomical data with fields:
- `channel_probe_name`: probe names for each channel
- `channel_area_targeted`: targeted brain areas
- `channel_XYZ_allen`: Allen CCF coordinates for channels
- `channel_area_allen`: Allen CCF area names for channels
- `channel_fullarea_allen`: Full Allen CCF area names
- `channel_goodchannelMap`: good channel mapping

### 3. behavioralstruct.mat
Contains behavioral data with fields:
- `behavior_event`: table with trial information including:
  - `start_time`: trial start times
  - `stop_time`: trial end times
  - `sound`: context information
  - `sound_frequency`: auditory stimulus frequency
  - `sound_amplitude`: auditory stimulus amplitude
  - `sound_starttime`: sound start times
  - `sound_duration`: sound durations
  - `whiskerstim`: whisker stimulation flags
  - `whiskerstim_amplitude`: whisker stimulation amplitude
  - `whiskerstim_starttime`: whisker stimulation start times
  - `whiskerstim_duration`: whisker stimulation durations
  - `optogenetics`: optogenetic stimulation flags
  - `opto_frequency`: optogenetic frequency
  - `opto_power`: laser power
  - `opto_starttime`: optogenetic start times
  - `opto_endtime`: optogenetic end times
  - `response`: lick response flags
  - `response_time`: lick response times
  - `completed_trial`: trial completion flags

### 4. Results.txt
Behavioral results file (imported as text data)

### 5. mouse_info.xlsx
Mouse metadata with columns:
- `age`: mouse age
- `date fo birth`: date of birth
- `starin`: mouse strain
- `sex`: mouse sex

### 6. Behavior_data.txt
Behavioral time series data containing:
- `tosave_Piezo_Lick_signal`: lick piezo signal
- `samplinRate`: sampling rate
- `valveopenning_time`: valve opening times
- `tosave_Laser_signal`: laser signal (if applicable)

### 7. Video_info.mat
Video metadata

### 8. poses.mat
DeepLabCut pose data with fields:
- `jawcord`: jaw coordinates
- `tonguecord`: tongue coordinates
- `Whisk_skel_angle`: whisker angles
- `snouta_snoutp_angle`: snout angles
- `Camera_TTL_edgeTime`: video timestamps

### 9. SLIM.mat
Contains probe information mapping

## Installation and Setup

### Prerequisites

1. **MATLAB** (R2018b or later recommended)
2. **matnwb library**: Download from [https://github.com/NeurodataWithoutBorders/matnwb](https://github.com/NeurodataWithoutBorders/matnwb)
3. **Helper functions**: Ensure the following files are in your MATLAB path:
   - `PrepareUnits_module.m`
   - `trial_typeMaker.m`
   - `ReadMeta.m`

### Setup Instructions

1. Clone or download this repository
2. Add the matnwb library to your MATLAB path:
   ```matlab
   addpath('path/to/matnwb');
   ```
3. Ensure all helper functions are in your MATLAB path
4. Update the configuration parameters in `Convert2NWB_Standalone.m`

## Usage

### 1. Configure Parameters

Edit the configuration section in `Convert2NWB_Standalone.m`:

```matlab
% Mouse information
params_converter.MouseNames = {'PG019'}; % Add your mouse names here
params_converter.directory = 'G:\G:\MiceFolders_ephys\'; % Set your data directory

% Optional parameters
params_converter.FS_RS_detection = 'automatic'; % 'automatic' or 'manual'
params_converter.thr_FS_RS_detection = [11, 14]; % Thresholds for FS/RS detection

% Add matnwb to path (adjust path as needed)
addpath('path/to/matnwb'); % Replace with your matnwb path
```

### 2. Run the Conversion

Execute the script in MATLAB:

```matlab
% Run the conversion
convert_to_nwb(params_converter);
```

### 3. Output

The script will create NWB files in the following structure:

```
MouseFolder-nwb/
└── SessionDate/
    └── SessionName/
        └── sub-MouseName_ses-SessionID-processed-behavior.nwb
```

## NWB File Structure

The generated NWB file contains:

### General Information
- Session metadata (description, experimenter, lab, etc.)
- Subject information (age, sex, strain, weight, etc.)

### Trial Information
- Trial start and stop times
- Stimulus parameters (auditory, whisker, optogenetic)
- Behavioral responses (licking, trial completion)
- Trial types (1: gotone_whisker, 2: gotone_nowhisker, 3: nogotone_whisker, 4: nogotone_nowhisker, 5: notone_whisker)

### Behavioral Data
- **Time Series**:
  - Jaw coordinates (pixels)
  - Tongue coordinates (pixels)
  - Whisker angles (degrees)
  - Snout angles (degrees)
  - Lick piezo trace (Volts)
- **Events**:
  - Valve opening times

### Electrophysiology Data
- **Electrode Information**:
  - Channel positions (Allen CCF coordinates)
  - Brain region annotations
  - Good/bad channel labels
- **Units**:
  - Spike times
  - Waveform shapes
  - Quality metrics
  - Unit classifications (RS/FS)
  - Firing rates
  - Anatomical locations

## Data Structure at Each Step

### Step 1: Data Loading
The script loads data from various sources:
- **Spike data**: From `Spikes.mat` files in each brain area
- **Anatomical data**: From `ANATOMY.mat` files for each probe
- **Behavioral data**: From `behavioralstruct.mat` and related files
- **Video data**: From DeepLabCut output files

### Step 2: NWB File Creation
Creates the main NWB file with session metadata and subject information.

### Step 3: Trial Information
Extracts trial data from behavioral structure and creates a comprehensive trial table with all stimulus and response parameters.

### Step 4: Behavioral Data
Processes behavioral time series data:
- **Pose data**: Extracts coordinates and angles from DeepLabCut
- **Lick data**: Processes piezo sensor data
- **Event data**: Extracts valve opening times

### Step 5: Electrophysiology Data
Processes spike data:
- **Electrode table**: Creates comprehensive electrode information
- **Units table**: Processes spike times, waveforms, and quality metrics
- **Anatomical mapping**: Links units to brain regions using Allen CCF

### Step 6: File Export
Saves the complete NWB file with all data integrated.

## Troubleshooting

### Common Issues

1. **Missing files**: Ensure all required data files are present in the correct locations
2. **Path issues**: Verify that matnwb and helper functions are in your MATLAB path
3. **Memory issues**: For large datasets, consider processing one session at a time
4. **File permissions**: Ensure write permissions for the output directory

### Error Messages

- `"SLIM.mat not found"`: Check that the SLIM file exists in the correct location
- `"Spikes.mat not found"`: Verify spike data files are in the expected structure
- `"ANATOMY.mat not found"`: Check anatomical data files
- `"Channel positions file not found"`: Update the path to the channel positions file

## Helper Functions

### PrepareUnits_module.m
Processes spike data to create unit information including:
- Quality metrics
- Anatomical locations
- Unit classifications
- Waveform characteristics

### trial_typeMaker.m
Creates trial type classifications based on stimulus combinations:
- 1: gotone_whisker
- 2: gotone_nowhisker
- 3: nogotone_whisker
- 4: nogotone_nowhisker
- 5: notone_whisker

### ReadMeta.m
Reads metadata from Neuropixels binary files to extract session information.

## Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Citation

If you use this code in your research, please cite:

```
@software{ghaderi_convert2nwb_2024,
  title={Convert2NWB: Neural Data to NWB Format Converter},
  author={Ghaderi, Parviz},
  year={2024},
  url={https://github.com/yourusername/VerifyNeural}
}
```

## Contact

For questions or issues, please contact:
- **Author**: Parviz Ghaderi
- **Email**: [your-email@example.com]
- **Lab**: LSENS, Brain Mind Institute, EPFL

## Acknowledgments

- Neurodata Without Borders (NWB) community
- matnwb development team
- DeepLabCut team
- Kilosort development team 