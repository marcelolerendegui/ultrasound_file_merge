function [wx, wy, wz] = scart2wcart(src_3d, sx, sy, sz)

    % camera transform matrix from source to world
    Rs = rotationVectorToMatrix(deg2rad(src_3d.dir_rot));
    ts = src_3d.position';
    Psw = [Rs ts ; [0 0 0] 1];
    
    % convert to 4 signle rows [x(:); y(:); z(:); 1(:)] for matrix multiplication
    ps_s_srow = [sx(:)'; sy(:)'; sz(:)'; ones(size(sz))'];
    
    ps_w_srow = Psw * ps_s_srow;
    
    wx = ps_w_srow(1,:);
    wy = ps_w_srow(2,:);
    wz = ps_w_srow(3,:);   

end