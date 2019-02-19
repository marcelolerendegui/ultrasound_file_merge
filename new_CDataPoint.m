function datapoint = new_CDataPoint()
    datapoint = struct();
	datapoint.line = 0;
	datapoint.exploso = 0;
	datapoint.sample = 0;
	datapoint.SectorType = 0; % either from B-mode or DB-mode sector
	datapoint.SliceNum = 0;   % for multi-slice scans
	datapoint.SectorNum = 0;  % for overlapping scans
end