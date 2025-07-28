# 🧠 Neural Data to NWB Conversion Pipeline

A comprehensive pipeline for converting neural data from post-processing format to NWB (Neurodata Without Borders) format, combining MATLAB processing with Python merging capabilities.

## 🎯 Motivation: Enabling FAIR Data Principles

### The Challenge of Complex Neural Data

Modern neuroscience experiments generate **highly complex, multi-modal datasets** that include:

- **Neural recordings**: Raw electrical signals from Neuropixels probes, spike-sorted data, LFP recordings
- **Behavioral data**: Video recordings, pose tracking (jaw, tongue, whisker movements), lick responses
- **Experimental metadata**: Trial information, stimulus parameters, optogenetic stimulation
- **Anatomical data**: Brain region mapping, Allen CCF coordinates, probe positioning
- **Subject information**: Mouse age, sex, strain, experimental history
- **Technical metadata**: Recording parameters, device information, synchronization data

### The FAIR Data Solution

This pipeline addresses the critical need for **FAIR data principles** in neuroscience:

- **🔍 Findable**: Standardized NWB format makes datasets discoverable and searchable
- **📂 Accessible**: Open, standardized format accessible to the entire research community
- **📊 Interoperable**: Compatible with the broader NWB ecosystem and analysis tools
- **♻️ Reusable**: Rich metadata and standardized structure enable data reuse and collaboration

### Why NWB Format?

The **Neurodata Without Borders (NWB)** format provides the ideal solution for complex neural datasets:

- **Comprehensive metadata**: Captures all experimental details and data relationships
- **Multi-modal support**: Handles neural, behavioral, and anatomical data in one file
- **Community standard**: Widely adopted in the neuroscience community
- **Rich ecosystem**: Extensive tool support for analysis, visualization, and sharing

> **📚 Learn More About NWB**: For detailed information about the NWB format, see the [NWB Documentation](https://nwb-schema.readthedocs.io/) and the foundational paper: [Yatsenko et al. (2022) - DataJoint: managing big scientific data using MATLAB or Python](https://elifesciences.org/articles/64389).

## 📋 Overview

This repository provides a **two-stage conversion process**:

1. **MATLAB Stage**: Creates processed NWB files with behavioral and spike data (lightweight)
2. **Python Stage**: Merges raw electrical signals from SpikeGLX with processed data (complete dataset)

## 🎯 Purpose

The pipeline addresses the challenge of creating comprehensive NWB datasets that include:
- **Processed neural data** (spike times, behavioral events, pose data)
- **Raw electrical signals** (LFP, AP signals from Neuropixels)
- **Behavioral recordings** (video files)
- **Complete metadata** (subject info, session details, anatomical data)

## 📁 Repository Structure

```
FAIRifyNeuro/
├── matlab/
│   ├── Convert2NWB_Standalone.m     # Main MATLAB conversion script
│   ├── PrepareUnits_module.m         # Helper function for unit processing
│   ├── trial_typeMaker.m            # Helper function for trial classification
│   ├── ReadMeta.m                   # Helper function for metadata reading
│   ├── Example_Usage_PG019.m        # Example usage script
│   └── README_Convert2NWB.md        # Detailed MATLAB documentation
├── python/
│   ├── merging_raw_processed.ipynb  # Python merging notebook
│   └── requirements.txt              # Python dependencies
├── docs/
│   ├── data_structure_guide.md      # Complete data structure documentation
│   └── workflow_diagram.md          # Visual workflow explanation
└── README.md                        # This file
```

## 🔄 Complete Workflow

### Stage 1: MATLAB Processing (Lightweight NWB Creation)

**Purpose**: Create processed NWB files containing behavioral data, spike times, and metadata without raw electrical signals.

**Input**: Post-processed neural data with the following structure:
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

**Output**: `-processed-behavior.nwb` files containing:
- ✅ Subject information (age, sex, strain, weight)
- ✅ Trial information (stimulus parameters, responses)
- ✅ Behavioral time series (jaw, tongue, whisker coordinates)
- ✅ Behavioral events (valve opening times)
- ✅ Electrophysiology data (spike times, waveforms, electrode info)
- ✅ Quality metrics and unit classifications
- ❌ **No raw electrical signals** (LFP/AP data)

### Stage 2: Python Merging (Complete Dataset Creation)

**Purpose**: Merge raw electrical signals from SpikeGLX with processed behavioral data to create complete NWB files.

**Input**: 
- `-processed-behavior.nwb` files (from MATLAB stage)
- SpikeGLX `.bin` files (raw electrical signals)

**Output**: `-processed-behavior-raw.nwb` files containing:
- ✅ All processed data from MATLAB stage
- ✅ **Raw electrical signals** (LFP, AP signals from Neuropixels)
- ✅ **Complete electrode information**
- ✅ **Device and acquisition metadata**

## 🚀 Quick Start

### Prerequisites

#### MATLAB Requirements
- MATLAB (R2018b or later)
- [matnwb library](https://github.com/NeurodataWithoutBorders/matnwb)
- Helper functions (included in repository)

#### Python Requirements
```bash
pip install -r python/requirements.txt
```

### Step 1: MATLAB Processing

1. **Configure parameters** in `matlab/Convert2NWB_Standalone.m`:
```matlab
params_converter.MouseNames = {'PG019'}; % Your mouse names
params_converter.directory = 'G:\G:\MiceFolders_ephys\'; % Your data path
addpath('path/to/matnwb'); % matnwb library path
```

2. **Run the conversion**:
```matlab
convert_to_nwb(params_converter);
```

3. **Verify output**: Check for `-processed-behavior.nwb` files in `MouseName-nwb/` folders.

### Step 2: Python Merging

1. **Open the Jupyter notebook**:
```bash
jupyter notebook python/merging_raw_processed.ipynb
```

2. **Configure the paths** in the notebook:
```python
directory = 'G:\\MiceFolders_ephys\\'
MouseNames = ['PG019-nwb']  # Your processed mouse folders
```

3. **Run the merging process**:
   - Cell 1: Creates raw NWB files from SpikeGLX data
   - Cell 2: Merges raw and processed data
   - Cell 3: (Optional) Attaches video files
   - Cell 4: Validates final NWB files

## 📊 Data Flow Explanation

### Why Two Stages?

**Stage 1 (MATLAB) - Lightweight Processing**:
- Processes complex behavioral data (pose tracking, trial events)
- Handles anatomical mapping and quality metrics
- Creates structured trial information
- **Fast and efficient** for behavioral analysis

**Stage 2 (Python) - Complete Dataset**:
- Adds raw electrical signals (essential for neural analysis)
- Merges different data streams properly
- Creates comprehensive datasets for sharing
- **Complete dataset** for full analysis

### File Naming Convention

| Stage | Input | Output | Description |
|-------|-------|--------|-------------|
| MATLAB | Post-processed data | `-processed-behavior.nwb` | Lightweight, behavioral focus |
| Python | Raw + Processed | `-processed-behavior-raw.nwb` | Complete dataset |

## 🔧 Detailed Documentation

### MATLAB Processing
- **[Convert2NWB_Standalone.m](matlab/Convert2NWB_Standalone.m)**: Main conversion script
- **[README_Convert2NWB.md](matlab/README_Convert2NWB.md)**: Complete MATLAB documentation
- **[Example_Usage_PG019.m](matlab/Example_Usage_PG019.m)**: Practical usage example

### Python Merging
- **[merging_raw_processed.ipynb](python/merging_raw_processed.ipynb)**: Complete merging workflow
- **Cell-by-cell explanation** in the notebook
- **Error handling** and validation included

### Data Structure
- **[data_structure_guide.md](docs/data_structure_guide.md)**: Complete data organization guide
- **[workflow_diagram.md](docs/workflow_diagram.md)**: Visual workflow explanation

## 🎯 Use Cases

### For Behavioral Analysis
Use `-processed-behavior.nwb` files (MATLAB output):
- Trial-by-trial analysis
- Behavioral event detection
- Pose tracking analysis
- Fast loading and processing

### For Neural Analysis
Use `-processed-behavior-raw.nwb` files (Python output):
- Spike train analysis
- LFP analysis
- Cross-modal correlations
- Complete dataset sharing

### For Data Sharing
Use `-processed-behavior-raw.nwb` files:
- Standardized NWB format
- Complete metadata
- Reproducible analysis
- Archive-ready datasets

## 🛠️ Troubleshooting

### Common MATLAB Issues
- **Missing files**: Check data structure requirements
- **Path issues**: Verify matnwb installation
- **Memory issues**: Process one session at a time

### Common Python Issues
- **Electrode mismatch**: Check probe configurations
- **File not found**: Verify SpikeGLX data paths
- **Validation errors**: Check NWB file integrity

## 📈 Performance Tips

### MATLAB Optimization
- Process one mouse at a time
- Use SSD storage for faster I/O
- Monitor memory usage for large datasets

### Python Optimization
- Use `link_data=False` for large files
- Validate files after merging
- Use `nwbinspector` for quality checks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your data
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Neurodata Without Borders (NWB)** community
- **matnwb** development team
- **neuroconv** development team
- **DeepLabCut** team
- **Kilosort** development team

## 📞 Contact

- **Author**: Parviz Ghaderi
- **Lab**: LSENS, Brain Mind Institute, EPFL
- **Email**: [parviz.ghaderi@epfl.ch]

## 📚 Citation

If you use this pipeline in your research, please cite:

```bibtex
@software{ghaderi_neural_nwb_pipeline_2025,
  title={Neural Data to NWB Conversion Pipeline},
  author={Ghaderi, Parviz},
  year={2024},
  url={https://github.com/yourusername/FAIRifyNeuro}
}
```

### NWB Format Citation

For the NWB format itself, please cite:

```bibtex
@article{yatsenko_datajoint_2022,
  title={DataJoint: managing big scientific data using MATLAB or Python},
  author={Yatsenko, Dimitri and Reimer, Jacob and Ecker, Alexander S and Walker, Edgar Y and Sinz, Fabian H and Berens, Philipp and Hoenselaar, Aki and Cotton, R James and Siapas, Athanassios G and Bethge, Matthias and others},
  journal={eLife},
  volume={11},
  pages={e64389},
  year={2022},
  publisher={eLife Sciences Publications, Ltd}
}
```

---

**🎉 Ready to convert your neural data to NWB format! Start with the MATLAB processing stage and then use Python to create complete datasets.** 