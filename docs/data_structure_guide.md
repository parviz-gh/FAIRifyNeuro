# 📁 Complete Data Structure Guide

This guide provides detailed information about the data structure requirements for the Neural Data to NWB Conversion Pipeline.

## 🎯 Overview

The pipeline requires a specific folder structure to process your neural data correctly. This structure organizes different types of data (electrophysiology, behavior, anatomy, video) in a hierarchical manner that the conversion scripts can understand.

## 📂 Required Folder Structure

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
│   ├── VIDEO/
│   │   └── RWA_VIDEO/
│   │       └── SessionDate/
│   │           └── SessionName/
│   │               └── DlcOut/
│   │                   ├── Video_info.mat
│   │                   └── poses.mat
│   └── SLIM/
│       └── SLIM.mat
```

## 📊 Detailed File Specifications

### 🧠 Electrophysiology Data

#### SpikeTime/BrainArea/Spikes.mat
**Purpose**: Contains processed spike data for each brain area
**Required Fields**:
- `times`: Spike times for each unit (vector)
- `cluster`: Cluster IDs from Kilosort (vector)
- `channel`: Channel numbers (vector)
- `Shape`: Waveform shapes (matrix)
- `RsUnits`: Regular spiking units (logical vector)
- `FsUnits`: Fast spiking units (logical vector)
- `Width`: Spike widths in ms (vector)
- `Amplitude`: Spike amplitudes in μV (vector)
- `Ypos`: Y positions on probe (vector)
- `Probe_name`: Probe names (cell array)
- `firingRate`: Firing rates in Hz (vector)
- `spikeCount`: Number of spikes per unit (vector)
- `QualityMatrix`: Quality metrics (matrix)

#### SessionName_t0.nidq.bin
**Purpose**: Raw SpikeGLX data file
**Format**: Binary file from SpikeGLX recording system
**Contains**: Raw electrical signals from Neuropixels

### 📈 Behavioral Data

#### EventTime/Behavior_data.txt
**Purpose**: Behavioral time series data
**Format**: Text file with structured data
**Required Fields**:
- `tosave_Piezo_Lick_signal`: Lick piezo signal (vector)
- `samplinRate`: Sampling rate in Hz (scalar)
- `valveopenning_time`: Valve opening times (vector)
- `tosave_Laser_signal`: Laser signal (vector, optional)

#### EventTime/Camera_TTL.txt
**Purpose**: Camera synchronization timestamps
**Format**: MATLAB .mat file
**Contains**: TTL pulse timestamps for video synchronization

#### EventTime/Camera_Arm.txt
**Purpose**: Camera arm movement timestamps
**Format**: MATLAB .mat file
**Contains**: Timestamps for camera arm movements

#### EventTime/Laser_Light.txt
**Purpose**: Laser stimulation timestamps
**Format**: MATLAB .mat file
**Contains**: Laser stimulation event timestamps

### 🐭 Mouse Information

#### BEHAVIOR/SessionDate/SessionName/mouse_info.xlsx
**Purpose**: Mouse metadata
**Format**: Excel file
**Required Columns**:
- `age`: Mouse age (text)
- `date fo birth`: Date of birth (text, format: dd/mm/yyyy)
- `starin`: Mouse strain (text)
- `sex`: Mouse sex (text: M/F)

#### BEHAVIOR/SessionDate/SessionName/Results.txt
**Purpose**: Behavioral results summary
**Format**: Text file
**Contains**: Summary of behavioral performance

#### BEHAVIOR/SessionDate/SessionName/behavioralstruct.mat
**Purpose**: Detailed behavioral data structure
**Format**: MATLAB .mat file
**Required Fields**:
- `behavior_event`: Table with trial information including:
  - `start_time`: Trial start times (vector)
  - `stop_time`: Trial end times (vector)
  - `sound`: Context information (cell array)
  - `sound_frequency`: Auditory stimulus frequency (vector)
  - `sound_amplitude`: Auditory stimulus amplitude (vector)
  - `sound_starttime`: Sound start times (vector)
  - `sound_duration`: Sound durations (vector)
  - `whiskerstim`: Whisker stimulation flags (logical vector)
  - `whiskerstim_amplitude`: Whisker stimulation amplitude (vector)
  - `whiskerstim_starttime`: Whisker stimulation start times (vector)
  - `whiskerstim_duration`: Whisker stimulation durations (vector)
  - `optogenetics`: Optogenetic stimulation flags (logical vector)
  - `opto_frequency`: Optogenetic frequency (vector)
  - `opto_power`: Laser power (vector)
  - `opto_starttime`: Optogenetic start times (vector)
  - `opto_endtime`: Optogenetic end times (vector)
  - `response`: Lick response flags (logical vector)
  - `response_time`: Lick response times (vector)
  - `completed_trial`: Trial completion flags (logical vector)

### 🧬 Anatomical Data

#### ANATOMY/SessionDate/SessionName/ProbeName/ANATOMY.mat
**Purpose**: Anatomical mapping information
**Format**: MATLAB .mat file
**Required Fields**:
- `channel_probe_name`: Probe names for each channel (cell array)
- `channel_area_targeted`: Targeted brain areas (cell array)
- `channel_XYZ_allen`: Allen CCF coordinates for channels (matrix)
- `channel_area_allen`: Allen CCF area names for channels (cell array)
- `channel_fullarea_allen`: Full Allen CCF area names (cell array)
- `channel_goodchannelMap`: Good channel mapping (structure)
- `cluster_XYZ_allen`: Allen CCF coordinates for clusters (matrix)
- `cluster_area_allen`: Allen CCF area names for clusters (cell array)
- `cluster_fullarea_allen`: Full Allen CCF area names for clusters (cell array)
- `cluster_depth_allen`: Depths in Allen CCF (vector)
- `cluster_area_targeted`: Targeted brain areas for clusters (cell array)

### 🎥 Video Data

#### VIDEO/RWA_VIDEO/SessionDate/SessionName/DlcOut/Video_info.mat
**Purpose**: Video metadata
**Format**: MATLAB .mat file
**Contains**: Video recording information and parameters

#### VIDEO/RWA_VIDEO/SessionDate/SessionName/DlcOut/poses.mat
**Purpose**: DeepLabCut pose tracking data
**Format**: MATLAB .mat file
**Required Fields**:
- `jawcord`: Jaw coordinates (cell array of vectors)
- `tonguecord`: Tongue coordinates (cell array of vectors)
- `Whisk_skel_angle`: Whisker angles (cell array of vectors)
- `snouta_snoutp_angle`: Snout angles (cell array of vectors)
- `Camera_TTL_edgeTime`: Video timestamps (cell array of vectors)

### 🔧 Configuration Data

#### RECORDING/SLIM/SLIM.mat
**Purpose**: Probe information mapping
**Format**: MATLAB .mat file
**Contains**: Mapping between probe names and brain areas

## 📋 Data Validation Checklist

Before running the conversion pipeline, verify that:

### ✅ File Structure
- [ ] All required directories exist
- [ ] File naming follows the specified convention
- [ ] No missing files in the structure

### ✅ Electrophysiology Data
- [ ] Spikes.mat files exist for each brain area
- [ ] All required fields are present in Spikes.mat
- [ ] SessionName_t0.nidq.bin files exist
- [ ] Data quality is acceptable

### ✅ Behavioral Data
- [ ] All EventTime files exist
- [ ] behavioralstruct.mat contains complete trial data
- [ ] mouse_info.xlsx has all required columns
- [ ] Results.txt is readable

### ✅ Anatomical Data
- [ ] ANATOMY.mat files exist for each probe
- [ ] All anatomical fields are present
- [ ] Coordinates are in the correct format

### ✅ Video Data
- [ ] Video_info.mat exists
- [ ] poses.mat contains all required pose data
- [ ] Timestamps are synchronized

### ✅ Configuration
- [ ] SLIM.mat exists and is readable
- [ ] Channel positions file is available

## 🚨 Common Issues and Solutions

### Missing Files
**Problem**: Required files are missing from the structure
**Solution**: 
1. Check file paths and naming conventions
2. Ensure all processing steps have been completed
3. Verify data transfer was successful

### Corrupted Data
**Problem**: Files exist but contain corrupted or incomplete data
**Solution**:
1. Re-run the data processing pipeline
2. Check for disk space issues
3. Verify data integrity

### Format Mismatches
**Problem**: Data format doesn't match expected structure
**Solution**:
1. Check field names and data types
2. Ensure compatibility with MATLAB version
3. Verify data processing pipeline output

### Path Issues
**Problem**: Scripts can't find required files
**Solution**:
1. Update directory paths in configuration
2. Check for special characters in file names
3. Ensure proper file permissions

## 📊 Data Quality Metrics

### Electrophysiology Quality
- **Spike Detection**: Clear spike waveforms
- **Signal-to-Noise Ratio**: >3:1 for good units
- **Firing Rate**: Reasonable rates (0.1-100 Hz)
- **Isolation Distance**: >20 for well-isolated units

### Behavioral Quality
- **Trial Completion**: >80% completed trials
- **Response Latency**: Consistent response times
- **Pose Tracking**: Clear tracking of body parts
- **Synchronization**: Proper timing alignment

### Anatomical Quality
- **Coordinate Accuracy**: Valid Allen CCF coordinates
- **Area Assignment**: Correct brain region labels
- **Depth Information**: Accurate depth measurements
- **Probe Alignment**: Proper probe positioning

## 🔄 Data Processing Pipeline

### Stage 1: Raw Data Collection
1. **SpikeGLX Recording**: Collect raw electrical signals
2. **Video Recording**: Record behavioral sessions
3. **Event Logging**: Log experimental events

### Stage 2: Data Processing
1. **Spike Sorting**: Kilosort processing
2. **Pose Tracking**: DeepLabCut analysis
3. **Event Extraction**: Behavioral event detection
4. **Anatomical Mapping**: Allen CCF registration

### Stage 3: Data Organization
1. **File Organization**: Arrange in required structure
2. **Data Validation**: Check completeness and quality
3. **Metadata Addition**: Add subject and session info

### Stage 4: NWB Conversion
1. **MATLAB Processing**: Create processed NWB files
2. **Python Merging**: Add raw electrical signals
3. **Validation**: Check NWB file integrity

## 📈 Performance Considerations

### Storage Requirements
- **Raw Data**: ~1-5 GB per session
- **Processed Data**: ~100-500 MB per session
- **NWB Files**: ~200-1 GB per session

### Processing Time
- **Spike Sorting**: 1-4 hours per session
- **Pose Tracking**: 2-6 hours per session
- **NWB Conversion**: 10-30 minutes per session

### Memory Usage
- **MATLAB Processing**: 2-8 GB RAM
- **Python Merging**: 4-16 GB RAM
- **File Validation**: 1-4 GB RAM

## 🤝 Support and Troubleshooting

For issues with data structure or file formats:

1. **Check the validation checklist** above
2. **Review error messages** carefully
3. **Verify file permissions** and paths
4. **Contact the development team** with specific error details

## 📚 Additional Resources

- [NWB Documentation](https://nwb-schema.readthedocs.io/)
- [matnwb GitHub](https://github.com/NeurodataWithoutBorders/matnwb)
- [neuroconv Documentation](https://neuroconv.readthedocs.io/)
- [DeepLabCut Documentation](https://github.com/DeepLabCut/DeepLabCut) 