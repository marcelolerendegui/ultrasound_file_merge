%% CleanUp
close all;
clear all;
clc;

%% Create 3D sources and grids for file1, file2 and output File

src1 = new_3DSource();
src1.position = [0,0,0];
src1.dir_rot  = [0, 0, 0];
src1.ax_span  = [1,10];
src1.az_span  = [-30,30];
src1.el_span  = [-30,30];

src2 = new_3DSource();
src2.position = [12,0,0];
src2.dir_rot  = [0, 0, 180];
src2.ax_span  = [1,10];
src2.az_span  = [-30,30];
src2.el_span  = [-30,30];

dst = new_3DSource();
dst.position = [6.5,0,8.5];
dst.dir_rot  = [0, -100, 0];
dst.ax_span  = [1, 10];
dst.az_span  = [-30,30];
dst.el_span  = [-30,30];

% dst = new_3DSource();
% dst.position = [0,0,0];
% dst.dir_rot  = [0, 0, 0];
% dst.ax_span  = [1,10];
% dst.az_span  = [-30,30];
% dst.el_span  = [-30,30];


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


%% Load Files
[data1, info1] = readUltrasoundFile('right side.VOL');
[data2, info2] = readUltrasoundFile('left side.VOL');

%% Create output data matrices

out_data1 = zeros(size(data1));
out_data2 = zeros(size(data1));

%% Get
out_data1 = get_srcdata_as_dst(src1, data1, dst, out_data1);
out_data2 = get_srcdata_as_dst(src2, data2, dst, out_data2);

out_data = 1*out_data1 + 1*out_data2;
out_data = uint8(out_data.*2^8);

[out] = SaveDataToFile('out.VOL', out_data);

