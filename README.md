# ultrasound_file_merge
Matlab scripts to read ultrasound files and merge them together into a single file

## Example
The file test_interp.m shows an example on how to merge T5 ultrasound files.
Remember to add *load_save*, *sources* and *coords* to Matlab's path.

Steps:
1. Create **3DSources** that represent each input transducer, and the virtual output transducer.
2. You can view the transducer pyramids in 3D with the function **plot_src_pyramid**.
3. Load the file data. The function **readUltrasoundFile** can handle VMI and T5D filetypes.
4. Use the function **get_src_ind_from_dst** to get the frame indices of an input 3DSource from the output 3DSource.
5. Use **interpn()** with the indices on step 4 to get the data viewed from the output 3DSource.
6. Repeat 3,4 & 5 for each input transducer.
7. Add the step 5 data from each transducer together.
8. Save to a file using: **SaveT5DataToFile* or **SaveDataToFile** (VMI).

The file test_read.m is an old implementation, will be removed in the future.
