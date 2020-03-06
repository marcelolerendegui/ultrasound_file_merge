function [X, Y, Z] = polar_grid_to_cartesian_grid(src_3d, AX, AZ, EL)

    [X, Y, Z] = sph2cart(deg2rad(AZ), deg2rad(EL), AX);
   
end