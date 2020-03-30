%% CleanUp
close all;
clearvars;
clc;


%% Create 3D sources and grids for left transducer, right transducer and output File
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


%% Load Files and extract frames

filepaths = [...
    "/mnt/media/duke/vr_lab/apnea_phantom/new/run1_Rfirst_Lsecond/full.t5d";...
    "/mnt/media/duke/vr_lab/apnea_phantom/new/run1_Rfirst_Lsecond/half.t5d";...
    "/mnt/media/duke/vr_lab/apnea_phantom/new/run1_Rfirst_Lsecond/oneThird.t5d";...
    "/mnt/media/duke/vr_lab/apnea_phantom/new/run1_Rfirst_Lsecond/onequarter.t5d"...
];

frames_left = [];
frames_right = [];

for i = 1:length(filepaths)
    fpath = str2mat(filepaths(i));
    [data, info] = readUltrasoundFile(fpath);
    
    left_frame = data(1,:,:,:);
    right_frame = data(end,:,:,:);
    
    frames_left = cat(1, frames_left, left_frame); % append left frame
    frames_right = cat(1, frames_right, right_frame); % append right frame
end

    
%% Get indices for left and right from out perspective

% dimensions of a single frame
frame_shape = size(data);
frame_shape(1) = [];

% get indices of right view from out perspective
[r2out_iax, r2out_iaz, r2out_iel] = ...
    get_src_ind_from_dst(srcR, frame_shape, dst, frame_shape);

% get indices of left view from out perspective
[l2out_iax, l2out_iaz, l2out_iel] = ...
    get_src_ind_from_dst(srcL, frame_shape, dst, frame_shape);



%% Get frames from out perspective
% apply out perspective to left frames
for i = size(frames_left, 1)
    frames_left(1,:,:,:) = interpn(frames_left, ...
    ones(frame_shape), l2out_iax, l2out_iaz, l2out_iel, ...
    'linear', ...
    0); % out of boundaries values turned to 0

end
% apply out perspective to right frames
for i = size(frames_right, 1)
    frames_right(1,:,:,:) = interpn(frames_right, ...
    ones(frame_shape), r2out_iax, r2out_iaz, r2out_iel, ...
    'linear', ...
    0); % out of boundaries values turned to 0

end

%% Combine frames and Save to *.T5a file

% combine
out_frames = frames_left + frames_right;

% expand size to fit out file
out_frames = cat(1, out_frames, zeros(49, 487, 64, 64));

% convert to int16
out_frames = int16(out_frames .* (2^16));

[out] = SaveT5DataToFile(...
    '/mnt/media/duke/vr_lab/apnea_phantom/new/run1_Rfirst_Lsecond/out.t5d', ...
    out_frames);


