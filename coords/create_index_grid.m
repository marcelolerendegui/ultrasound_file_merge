function [n_ax, n_az, n_el] = create_index_grid(ax_nsamples, az_nsamples, el_nsamples)

    [n_ax, n_az, n_el] = ndgrid(1:ax_nsamples, ...
                                1:az_nsamples, ...
                                1:el_nsamples);
                    
end