function scanformat = new_CScanFormat()
    
    eval('load_constants') % load constants

    % Create new CScanFormat structure    
    scanformat = struct();

    scanformat.LineCount = 0;
    scanformat.LineLength = 0;
    scanformat.ConvType = 0;
    scanformat.AngularSpacing = 0;
    scanformat.ExplosoCount = 0;
    scanformat.ScanDepth = 0;
    scanformat.ExplosoMap = zeros(1, MAX_LINE_COUNT*MAX_EXPLOSOS*2);
    scanformat.ModeWord = 0;
    scanformat.Apertures = 0;
    scanformat.isGated = false;
    scanformat.Source = 0;
    scanformat.NumPlanes = 0;
    scanformat.Elspacing = 0;  % Should only be used for Multi-B Scans
    scanformat.ROffset = 0;
    scanformat.ApertureOffset = 0;	% for multi-aperture scans (in um)
    scanformat.FOV = 0;			% Field of View (in 1000ths of degrees)
end