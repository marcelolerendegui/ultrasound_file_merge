%% CleanUp
close all;
clear all;
clc;

%% Load Files
[status, info, header, Frames] = ...
    LoadT5DataFromFile('apnea_phantom/coated_tapered_bulb.t5d');

%% Reshape
data = Frames(1).Data .* 255 ./  32767;

orig_dims = [404, 32, 4, 32, 4];
% all possible scrambles
all_scr = perms([1,2,3,4,5]);

% all_scr = [ ...
%      1,3,5,2,4 ;...
%      1,5,3,2,4 ;...
%      1,3,5,4,2 ;...
%      1,5,3,4,2 ;...
%      ];

all_scr = [1,3,5,2,4];

for i = 1:size(all_scr,1)
    scr = all_scr(i,:);
    uns = unscramble(scr);
    dims = orig_dims(scr);

    new_data = reshape(data, dims);
    new_data = permute(new_data, scr);
    new_data = reshape(new_data, [404, 128, 128]);

    hf = figure('Name', [num2str(i) mat2str(scr)]);
    subplot(1,3,1);
    imshow(squeeze(new_data(202, :, :)));
    subplot(1,3,2);
    imshow(squeeze(new_data(:, 64, :)));
    subplot(1,3,3);
    imshow(squeeze(new_data(:, :, 64)));
    close(gcf);
end
