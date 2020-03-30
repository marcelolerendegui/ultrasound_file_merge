%% CleanUp
close all;
clearvars;
clc;


%% Create 3D sources and grids for file1, file2 and output File
% Pyramid position, rotation and span in world coordinates
srcL = new_3DSource();
srcL.position = [0, 0, 0];
srcL.dir_rot  = [0, 0, 0];
srcL.ax_span  = [1, 10];
srcL.az_span  = [-20, 20];
srcL.el_span  = [-20, 20];

srcR = new_3DSource();
srcR.position = [14.5, 0, 0];
srcR.dir_rot  = [0, 0, 180];
srcR.ax_span  = [1, 10];
srcR.az_span  = [-20, 20];
srcR.el_span  = [-20, 20];

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
plot_src_pyramid(ha, srcL, 100, 'b');
plot_src_pyramid(ha, srcR, 100, 'r');
plot_src_pyramid(ha, dst, 100, 'g');
xlabel(ha, 'x');
ylabel(ha, 'y');
zlabel(ha, 'z');
grid(ha, 'on');
legend(ha, 'Left', 'Right', 'output');
axis equal


%% Load Files
filepath = 'data/full.t5d';
[data, info] = readUltrasoundFile(filepath);


%% Test Plot Slices


% First Frame
hf1 = figure();
ha1 = axes();
imagesc(ha1,squeeze(data(1,:,32,:)));colormap('gray');

% Last Frame
hf2 = figure();
ha2 = axes();
imagesc(ha2,squeeze(data(end,:,32,:)));colormap('gray');

%% Get first and last frame from output perspective
% dimensions of a single frame
frame_shape = size(data);
frame_shape(1) = [];

% get indices of right view from out perspective
[r2out_iax, r2out_iaz, r2out_iel] = ...
    get_src_ind_from_dst(srcR, frame_shape, dst, frame_shape);

% get indices of left view from out perspective
[l2out_iax, l2out_iaz, l2out_iel] = ...
    get_src_ind_from_dst(srcL, frame_shape, dst, frame_shape);

% get frames from out perspective
frameR_out = interpn(data, ...
    ones(frame_shape), r2out_iax, r2out_iaz, r2out_iel, ...
    'linear', ...
    0); % out of boundaries values turned to 0

frameL_out = interpn(data, ...
    53*ones(frame_shape), l2out_iax, l2out_iaz, l2out_iel,...
    'linear', ...
    0); % out of boundaries values turned to 0

%% Test Plot slices 
hf3 = figure();
ha3 = axes();
imagesc(ha3,squeeze(frameR_out(:,32,:)));colormap('gray');

hf4 = figure();
ha4 = axes();
imagesc(ha4,squeeze(frameL_out(:,32,:)));colormap('gray');

%% Combine images

out_frame = 0.5*frameR_out + 0.5*frameL_out;

hf5 = figure();
ha5 = axes();
imagesc(ha5,squeeze(out_frame(:,32,:)));colormap('gray');


%% Create out data
% create empty out_data
out_data = zeros(size(data), 'int16');

% convert out_frame to int16
out_frame = int16(out_frame .* (2^16));

% write out_frame to first out_data frame
out_data(1,:,:,:) = out_frame;


%% Save to *.T5a file
[out] = SaveT5DataToFile(...
    'data/out.t5d', ...
    out_data);


