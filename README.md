

# DiffusionRecon


## Installation

Add the folders and subfolders to your path or run the install script before using the recon

```matlab
Install_DiffRecon
```

## Internal Data format

The reconstruction are run using the following data format 
Dcm [ X Y Slices b-values Directions Averages ]

## Single volume recon

To reconstruct single case using the script "Script_Recon_DTI_KM.m"

```matlab
Script_Recon_DTI_KM
```

Select the folder that containts only the DWI dicom.
Select the Recon Options and run.
Reconstructions for each reconstruction step are stored in a Mat file format in the newly created "Maps" folder.

## Multi-volume recon - Batch Manager

To reconstruct several cases at once use the Batch Manager

```matlab
Batch_Manager_KM
```

A graphical UI will appears.
Create a New Batch file in a folder above the Dicoms data you would like to recon. 


![alt text](https://github.com/KMoulin/DiffusionRecon-v2/blob/main/Doc/Main.jpg?raw=true)
 
Select the Recon Options and run.
The Batch Manager will then analyze all the subfolders and recreate Dicoms series (The process is very long).
Then the series will be loaded on the UI


![alt text](https://github.com/KMoulin/DiffusionRecon-v2/blob/main/Doc/Loaded.jpg?raw=true)

If you add additional files and folders later on, you can use the "Update Batch" button to load them in the UI. 
You can change the Recon Option using the "Recon Options" button. 
You can reload a Batch file using the "Load Batch" button. 

### Run Batch

When you are ready to run the recon, use the "Run Batch" button. The diffusion reconstruction will be run on each selected series. 

Reconstruction for each reconstruction step is stored in a Mat file format in the newly created "Batch_Recon" folder.
Final Dicom Reconstructions  will be stored in the "Dicom_Recon" folder.

This option will call the script called "script_batch_cDTI_KM.m" which can be modified by the user. 

### ROI Batch

After you finish with the Recon, you can use the "ROI Batch" button to manually draw the ROI on the LV. 
This will also reconstruct the HA/TRA/E2A maps based on the LV countour and recrate the corresponding Dicoms.

This option will call the script called "script_batch_ROI_KM.m" which can be modified by the user. 

### Dicom Batch

The "Dicom Batch" button manually re-run the Dicom creation step. 

This option will call the script called "script_batch_DICOM_KM.m" which can be modified by the user. 

### add Batch

The "Additional Script" button run an empty script "script_add_batch_KM.m" which can be modified by the user. 

## Recon Options

![alt text](https://github.com/KMoulin/DiffusionRecon-v2/blob/main/Doc/Options.jpg?raw=true)

### Interpolation 
Perform 2X interpolation of the reconstructed maps.

### Avg and Reject
Perform averaging but remove pixel that would generate an ADC >3x10-3mm2/s 
Can be use to filter out bad acquisitions

### PCA
Perform a PCA filtering on the Average Dimension
See PCAtMIP approach(Pai VM, Rapacchi S, Kellman P, et al. PCATMIP: Enhancing signal intensity in diffusionweighted magnetic resonance imaging. Magn Reson Med. 2010; 65 DOI: 10.1002/mrm. 22748.)

### tMIP
Perform a Maximun Intensity Projection on the Average Dimension
See PCAtMIP approach (Pai VM, Rapacchi S, Kellman P, et al. PCATMIP: Enhancing signal intensity in diffusionweighted magnetic resonance imaging. Magn Reson Med. 2010; 65 DOI: 10.1002/mrm. 22748.)

### Avg
Perform standard averaging on the Average Dimension

### Rigid Reg.
Perform a first Rigid Registration on the Average Dimension and then a second Rigid Registration after averaging on the b-values and Direction dimensions

### Non-Rigid Reg.
Perform a non-Rigid Registration on the Average Dimension 

### Mask
Create a simple Mask

### ROI
Draw a manual ROI. NOT RECOMMENDED WITH BATCH RECON USE "BATCH ROI" INSTEAD !
Also generate an 6 segment AHA mask and a LV transmural Mask

### Trace
Calculate the image Trace over the Direction Dimension

### DTI
Calculate the diffusion TENSOR per b-value and generate EigenVector, EigenValues, MD and FA maps

### IVIM
Non suported

## Unmosaic
Remove the mosaic from old Siemens version (VE11 and inferior). Works only if the mosaic is detected. Recommended to always keep it on. 

## GIF
Save an animated GIF for each reconstruction step. Useful for debug. Takes same memory so not recommended with the Batch Manager. 

