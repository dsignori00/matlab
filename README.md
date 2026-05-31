# polimove

MATLAB scripts and utilities for PoliMOVE data analysis, with a focus on:
- autonomous racing telemetry and lap analysis
- perception (radar/lidar/camera) detection and tracking analysis
- off-road row-filter analysis

## Repository structure

- `polimove/`
  - `autonoma/`: lap-time and opponent-comparison analysis
  - `perception/`: detection/tracking/offline analysis
  - `common/`: shared plotting/scripts/utilities
  - `databases/`: track database `.mat` files (IMS, LVMS, Laguna Seca, Yas Marina, Yas North)
  - `bags/`: input logs (`.mat`) used by analysis scripts
- `offroad/merlo/row_filter/`: off-road row-filter analysis and plots
- `common/`: shared constants/graphics/utils used across modules

## Prerequisites

- MATLAB (tested on R2024a)
- Input data as `.mat` files (or CSV bags converted to `.mat`)
- Optional: CasADi for `polimove/autonoma/opponent_comparison/main.m` (`import casadi.*`)

## Recommended startup (MATLAB Project style)

There is no committed `.prj` file, but you can still work as a MATLAB project:

1. Open MATLAB.
2. Go to **Home → New → Project → From Existing Folder**.
3. Select the repository root folder.
4. Save the project locally (MATLAB creates local project metadata).

This makes it easier to keep paths and working folder consistent while running scripts.

## How to run analyses

> Important: many scripts use relative `addpath(...)`; run each script with MATLAB current folder set to that script's folder.

### 1) Standard PoliMOVE analyses

Input logs go in:
- `polimove/bags/*.mat`

Typical entry points:
- `polimove/perception/tracking/TargetTrackingAnalysis/TargetTrackingAnalysis.m`
- `polimove/perception/detection/RadarAnalysis.m`
- `polimove/perception/detection/CompareFov.m`
- `polimove/autonoma/LapTimeAnalysis.m`
- `polimove/autonoma/opponent_comparison/main.m`

Workflow:
1. In MATLAB, set Current Folder to the script directory.
2. Run the script.
3. When prompted, select:
   - a track database from `polimove/databases/`
   - one or more `.mat` log files from `polimove/bags/` (or other prompt-specific folders)
4. Inspect generated figures.

### 2) Off-road row-filter analysis

Input logs go in:
- `offroad/merlo/row_filter/bags/*.mat`

Run:
- `offroad/merlo/row_filter/RowFilterAnalysis.m`

### 3) Convert parsed CSV bags to `.mat`

If your source data is CSV (for example ROS parsed topics), use:
- `polimove/common/scripts/TopicsCsvToMat.m`

The script prompts for one or more bag folders (expects a `Parsed_Data/` subfolder) and generates `.mat` logs.

## Data notes

- Placeholder `.gitkeep` files are kept in bag folders; real bag files are ignored by git.
- Large datasets are expected to be local and not versioned.

## Author

Daniele Signori
- GitHub: [@dsignori00](https://github.com/dsignori00)
- LinkedIn: [daniele-signori](https://www.linkedin.com/in/daniele-signori/)

## Contributing

Contributions, issues, and feature requests are welcome.

## Support

If this repository is useful to you, leave a ⭐ on GitHub.
