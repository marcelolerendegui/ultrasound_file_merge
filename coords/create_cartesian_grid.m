function [X, Y, Z] = create_cartesian_grid(src_3d, nsamples)

[ax_nsamples, az_nsamples, el_nsamples] = nsamples;

[AX, AZ, EL] = create_polar_grid(src_3d,... 
                                 ax_nsamples,...
                                 az_nsamples,...
                                 el_nsamples);
[X, Y, Z] = polar_grid_to_cartesian_grid(src_3d, AX, AZ, EL);

end