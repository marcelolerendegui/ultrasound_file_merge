function [indx_ax, indx_az, indx_el] = get_src_ind_from_dst(src3d, src_shape, dst3d, dst_shape)
    %% Camera Transformation Matrices
    % source to world
    Rs = rotationVectorToMatrix(deg2rad(src3d.dir_rot));
    ts = src3d.position';
    Psw = [Rs ts ; [0 0 0] 1];
    % dest to world
    Rd = rotationVectorToMatrix(deg2rad(dst3d.dir_rot));
    td = dst3d.position';
    Pdw = [Rd td ; [0 0 0] 1];

    %% Create coords for dest

    % Dst Dimensions
    d_nax = dst_shape(1);
    d_naz = dst_shape(2);
    d_nel = dst_shape(3);
    
    % Coords
    [AXs, AZs, ELs] = create_polar_grid(dst3d,... 
                                        d_nax,...
                                        d_naz,...
                                        d_nel,...
                                        "nd");

    [xs, ys, zs] = polar_grid_to_cartesian_grid(dst3d, AXs, AZs, ELs);

    %% Create stack to apply transformations
    % dst_stack = [x(N_AX,N_AZ,N_EL); y(N_AX,N_AZ,N_EL); z(N_AX,N_AZ,N_EL); 1(N_AX,N_AZ,N_EL)]
    % size(dst_stack) => [DEPTH, WIDTH, HEIGHT, 4]
    stack = cat(4, xs, ys, zs, ones(size(xs)));
    % ps_s = [4, DEPTH, WIDTH, HEIGHT]
    stack = permute(stack,[4, 1, 2, 3]);
    % convert to 4 signle rows [x(:); y(:); z(:); 1(:)] for matrix multiplication
    stack = reshape(stack, 4, []);

    %% Apply transformations
    % backwards problem: from dest perspective to source perspective
    % DEST --Pdw--> WORLD --inv(Psw)--> SOURCE
    % DEST --Pdw--> WORLD 
    stack = Pdw * stack;
    % WORLD --inv(Psw)--> SOURCE
    stack = Psw\stack; %faster than inv(Psw) * stack;

    % convert to back to row stack to stack of 4 tridimentional matrices
    % size => [4, DEPTH, WIDTH, HEIGHT]
    stack = reshape(stack, 4, d_nax, d_naz, d_nel);


    %% Convert coords to spherical
    %                       x               y               z             
    [az, el, ax] = cart2sph(stack(1,:,:,:), stack(2,:,:,:), stack(3,:,:,:));

    % remove singleton dimensions
    az = rad2deg(squeeze(az));
    el = rad2deg(squeeze(el));
    ax = squeeze(ax);

    %% Convert dst spherical coordinates to indices 
    % ax = (indx * delta_ax + ax_min) 

    % Source Dimensions
    s_nax = src_shape(1);
    s_naz = src_shape(2);
    s_nel = src_shape(3);
    
    % Calculate deltas
    s_delta_ax = (src3d.ax_span(2) - src3d.ax_span(1))/s_nax;
    s_delta_az = (src3d.az_span(2) - src3d.az_span(1))/s_naz;
    s_delta_el = (src3d.el_span(2) - src3d.el_span(1))/s_nel;

    % Turn spherical coordinates to indices
    indx_ax = (ax - src3d.ax_span(1))./s_delta_ax;
    indx_az = (az - src3d.az_span(1))./s_delta_az;
    indx_el = (el - src3d.el_span(1))./s_delta_el;

end