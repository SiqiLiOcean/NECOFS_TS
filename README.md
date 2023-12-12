# NECOFS_TS
Create temperature and salinity data assimilation input files for NECOFS
by Siqi Li, Lu Wang, and Changsheng Chen, SMAST.

Required libraries:
- matFVCOM: https://github.com/SiqiLiOcean/matFVCOM
- matFigure: https://github.com/SiqiLiOcean/matFigure

Steps:
- Step 1: Read the original dataset and write in the TS struct format
- Step 2: Write data for the regional FVCOM model
- Step 3: Manually remove the data in bad quality (optional)
