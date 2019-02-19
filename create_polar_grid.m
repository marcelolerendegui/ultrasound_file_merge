function [AX, AZ, EL] = create_polar_grid(src_3d, ax_nsamples, az_nsamples, el_nsamples)

[AX, AZ, EL] = ndgrid(  linspace(src_3d.ax_span(1), src_3d.ax_span(2), ax_nsamples), ...
                        linspace(src_3d.az_span(1), src_3d.az_span(2), az_nsamples), ...
                        linspace(src_3d.el_span(1), src_3d.el_span(2), el_nsamples));
                    
end