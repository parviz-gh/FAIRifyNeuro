# 🔄 Workflow Diagram and Process Explanation

This document provides a visual and detailed explanation of how the two-stage NWB conversion pipeline works.

## 🎯 Overview

The pipeline combines MATLAB processing (for complex behavioral data) with Python merging (for raw electrical signals) to create comprehensive NWB datasets.

## 📊 Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INPUT DATA STRUCTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  MouseFolder/                                                              │
│  ├── RECORDING/ELECTROPHYSIOLOGY/SessionDate/SessionName/                  │
│  │   ├── SpikeTime/BrainArea/Spikes.mat                                    │
│  │   ├── EventTime/Behavior_data.txt                                       │
│  │   └── SessionName_t0.nidq.bin                                          │
│  ├── RECORDING/BEHAVIOR/SessionDate/SessionName/                          │
│  │   ├── behavioralstruct.mat                                              │
│  │   └── mouse_info.xlsx                                                   │
│  ├── RECORDING/ANATOMY/SessionDate/SessionName/ProbeName/ANATOMY.mat      │
│  ├── RECORDING/VIDEO/RWA_VIDEO/SessionDate/SessionName/DlcOut/poses.mat   │
│  └── RECORDING/SLIM/SLIM.mat                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        STAGE 1: MATLAB PROCESSING                          │
│                    (Creates Lightweight NWB Files)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │   Load Data     │    │  Create NWB     │    │  Add Subject    │        │
│  │   Structures    │───▶│   File          │───▶│   Information   │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│           │                       │                       │                 │
│           ▼                       ▼                       ▼                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │  Add Trial      │    │  Add Behavioral │    │  Add Ephys      │        │
│  │  Information    │    │  Time Series    │    │  Data           │        │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│           │                       │                       │                 │
│           └───────────────────────┼───────────────────────┘                 │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                    Save -processed-behavior.nwb                      │ │
│  │                                                                       │ │
│  │  ✅ Subject info, trials, behavioral data, spike times              │ │
│  │  ✅ Quality metrics, anatomical mapping                              │ │
│  │  ❌ No raw electrical signals (LFP/AP)                              │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        STAGE 2: PYTHON MERGING                            │
│                   (Adds Raw Electrical Signals)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│  │  Load Raw       │    │  Load Processed │    │  Merge Data     │        │
│  │  SpikeGLX       │    │  NWB File       │    │  Streams        │        │
│  │  Data           │    │  (-processed-   │    │   behavior.nwb) │    │
│  └─────────────────┘    └─────────────────┘              │                 │
│           │             └─────────────────┘              │                 │
│           │                       │                      │                 │
│           └───────────────────────┼──────────────────────┘                 │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                 Save -processed-behavior-raw.nwb                     │ │
│  │                                                                       │ │
│  │  ✅ All processed data from MATLAB stage                             │ │
│  │  ✅ Raw electrical signals (LFP, AP from Neuropixels)               │ │
│  │  ✅ Complete electrode information                                   │ │
│  │  ✅ Device and acquisition metadata                                  │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FINAL OUTPUT                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Complete NWB Dataset:                                                     │
│  - Standardized format for data sharing                                    │
│  - Comprehensive metadata and annotations                                  │
│  - Raw and processed data in one file                                     │
│  - Compatible with NWB ecosystem tools                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔍 Detailed Process Explanation

### Stage 1: MATLAB Processing

**Purpose**: Create lightweight NWB files focused on behavioral and processed neural data.

**Process Flow**:

1. **Data Loading**
   - Load `Spikes.mat` files for each brain area
   - Load `behavioralstruct.mat` for trial information
   - Load `ANATOMY.mat` for anatomical mapping
   - Load `poses.mat` for behavioral pose data
   - Load `mouse_info.xlsx` for subject metadata

2. **NWB File Creation**
   - Create main NWB file with session metadata
   - Extract session start time from SpikeGLX metadata
   - Generate unique session identifier

3. **Subject Information**
   - Add mouse age, sex, strain, weight
   - Include date of birth and description
   - Link to subject metadata

4. **Trial Information**
   - Extract trial start/stop times
   - Add stimulus parameters (auditory, whisker, optogenetic)
   - Include behavioral responses (licking, completion)
   - Create trial type classifications

5. **Behavioral Data**
   - Add pose tracking data (jaw, tongue, whisker, snout)
   - Include lick piezo signals
   - Add valve opening events
   - Create behavioral time series

6. **Electrophysiology Data**
   - Process spike times and waveforms
   - Add electrode information and anatomical mapping
   - Include quality metrics and unit classifications
   - Create units table with all metadata

**Output**: `-processed-behavior.nwb` files containing all processed data but no raw electrical signals.

### Stage 2: Python Merging

**Purpose**: Add raw electrical signals from SpikeGLX to create complete datasets.

**Process Flow**:

1. **Raw Data Processing**
   - Load SpikeGLX `.bin` files
   - Extract LFP and AP signals
   - Create raw NWB files with electrical data
   - Handle multiple data streams if present

2. **Data Merging**
   - Load processed NWB files from MATLAB stage
   - Load raw NWB files from SpikeGLX conversion
   - Merge electrode information properly
   - Handle electrode reference mapping

3. **Stream Integration**
   - Add electrical series to processed files
   - Maintain proper electrode references
   - Preserve all metadata and annotations
   - Handle multi-probe setups

4. **Validation**
   - Check file integrity
   - Validate electrode references
   - Ensure data consistency
   - Run NWB compliance checks

**Output**: `-processed-behavior-raw.nwb` files containing complete datasets.

## 📊 Data Flow Comparison

| Aspect | MATLAB Stage | Python Stage |
|--------|--------------|--------------|
| **Focus** | Behavioral & Processed | Raw Electrical |
| **Data Type** | Spike times, trials, poses | LFP, AP signals |
| **File Size** | Small (100-500 MB) | Large (200-1 GB) |
| **Processing Speed** | Fast (10-30 min) | Moderate (30-60 min) |
| **Memory Usage** | Low (2-8 GB) | High (4-16 GB) |
| **Use Case** | Behavioral analysis | Neural analysis |

## 🎯 Why Two Stages?

### MATLAB Advantages for Stage 1:
- **Complex Data Processing**: Handles behavioral data structures efficiently
- **Anatomical Mapping**: Processes Allen CCF coordinates and brain regions
- **Quality Metrics**: Calculates spike quality and unit classifications
- **Trial Organization**: Creates comprehensive trial tables with multiple parameters
- **Fast Processing**: Efficient for behavioral data without raw signals

### Python Advantages for Stage 2:
- **Raw Data Handling**: Efficiently processes large binary files
- **Stream Management**: Handles multiple data streams from Neuropixels
- **Memory Management**: Better for large datasets
- **NWB Ecosystem**: Native support for NWB format and tools
- **Validation**: Built-in NWB compliance checking

## 🔄 File Naming Convention

| Stage | Input | Output | Description |
|-------|-------|--------|-------------|
| MATLAB | Post-processed data | `-processed-behavior.nwb` | Lightweight, behavioral focus |
| Python | Raw + Processed | `-processed-behavior-raw.nwb` | Complete dataset |

## 📈 Performance Considerations

### MATLAB Stage Optimization:
- Process one mouse at a time
- Use SSD storage for faster I/O
- Monitor memory usage for large datasets
- Validate data structure before processing

### Python Stage Optimization:
- Use `link_data=False` for large files
- Validate files after merging
- Use `nwbinspector` for quality checks
- Handle memory efficiently for large datasets

## 🛠️ Troubleshooting Workflow

### Stage 1 Issues:
1. **Missing Files**: Check data structure requirements
2. **Path Issues**: Verify matnwb installation
3. **Memory Issues**: Process one session at a time
4. **Format Errors**: Check field names and data types

### Stage 2 Issues:
1. **Electrode Mismatch**: Check probe configurations
2. **File Not Found**: Verify SpikeGLX data paths
3. **Validation Errors**: Check NWB file integrity
4. **Memory Issues**: Use appropriate chunk sizes

## 🎯 Use Case Scenarios

### For Behavioral Analysis:
Use `-processed-behavior.nwb` files (MATLAB output):
- Trial-by-trial analysis
- Behavioral event detection
- Pose tracking analysis
- Fast loading and processing

### For Neural Analysis:
Use `-processed-behavior-raw.nwb` files (Python output):
- Spike train analysis
- LFP analysis
- Cross-modal correlations
- Complete dataset sharing

### For Data Sharing:
Use `-processed-behavior-raw.nwb` files:
- Standardized NWB format
- Complete metadata
- Reproducible analysis
- Archive-ready datasets

## 🔍 Quality Control Points

### Stage 1 Quality Checks:
- [ ] All required files present
- [ ] Data structure validation
- [ ] Field completeness check
- [ ] Metadata accuracy
- [ ] Trial information completeness

### Stage 2 Quality Checks:
- [ ] Raw data integrity
- [ ] Electrode reference mapping
- [ ] Stream synchronization
- [ ] NWB compliance
- [ ] File size validation

## 📚 Additional Resources

- [NWB Schema Documentation](https://nwb-schema.readthedocs.io/)
- [matnwb GitHub Repository](https://github.com/NeurodataWithoutBorders/matnwb)
- [neuroconv Documentation](https://neuroconv.readthedocs.io/)
- [SpikeGLX Documentation](https://billkarsh.github.io/SpikeGLX/)

---

**This workflow ensures that your neural data is properly converted to NWB format with both processed behavioral data and raw electrical signals, creating comprehensive datasets suitable for analysis and sharing.** 