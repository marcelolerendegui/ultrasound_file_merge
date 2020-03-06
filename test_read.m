%% CleanUp
close all;
clear all;
clc;

%% Create 3D sources and grids for file1, file2 and output File

src1 = new_3DSource();
src1.position = [0, 0, 0];
src1.dir_rot  = [0, -3, 0];
src1.ax_span  = [1, 10];
src1.az_span  = [-20, 20];
src1.el_span  = [-20, 20];

src2 = new_3DSource();
src2.position = [14.5, 0, 0];
src2.dir_rot  = [0, 0, 180];
src2.ax_span  = [1, 10];
src2.az_span  = [-20, 20];
src2.el_span  = [-20, 20];

dst = new_3DSource();
dst.position = [7.25, 0, 7.5];
dst.dir_rot  = [0, -90, 0];
dst.ax_span  = [1, 15];
dst.az_span  = [-40, 40];
dst.el_span  = [-40, 40];

dst = new_3DSource();
dst.position = [13, 0, 0];
dst.dir_rot  = [0, 0, 180];
dst.ax_span  = [1, 10];
dst.az_span  = [-20, 20];
dst.el_span  = [-20, 20];

%% Plot the sources
hf = figure('Name', 'Sources', 'Numbertitle', 'off');
ha = axes;
hold(ha, 'on');
plot_src_pyramid(ha, src1, 100, 'b');
plot_src_pyramid(ha, src2, 100, 'r');
plot_src_pyramid(ha, dst, 100, 'g');
xlabel(ha, 'x');
ylabel(ha, 'y');
zlabel(ha, 'z');
grid(ha, 'on');
legend(ha, 'file1', 'file2', 'output');
axis equal

%% Load Files
[data1, info1] = readUltrasoundFile('apnea_phantom/CTB_right_14cm neck.t5d');
[data2, info2] = readUltrasoundFile('apnea_phantom/CTB_left_14cm neck.t5d');

%% Create output data matrices

out_data1 = zeros(size(data1));
out_data2 = zeros(size(data1));

%data1f = flip(data1, 4);

%% Get
out_data1 = get_srcdata_as_dst(src1, data1f, dst, out_data1);
out_data2 = get_srcdata_as_dst(src2, data2, dst, out_data2);

out_data = 1*out_data1 + 1*out_data2;
out_data = uint16(out_data.*2^16);

%% Save
[out] = SaveT5DataToFile('out4.t5d', out_data);
% [out1] = SaveT5DataToFile('a.t5d', out_data1);
% [out2] = SaveT5DataToFile('b.t5d', out_data2);

