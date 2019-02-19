function header = new_CFileHeader()
    header = struct();
	header.Version = 0;
	header.FrameCount = 0;
	header.LineCount = 0;
	header.ExplosoCount = 0;
	header.LineLength = 0;
	header.ScanDepth = 0;
	header.Caption = "";
	header.Description = "";
	header.ConvType = 0;
	header.AngularSpacing = 0;
	header.CPUSpeed = 0;
	header.ModeWord = 0;
    header.NumPlanes = 0;
    header.Elspacing = 0;
	header.XDucerName = "";
	header.Frequency = 0;	% #new
	header.AcqRate = 0;
	header.ECGAcqRate = 0;
	header.Filter = "";
	header.CtrlVersion = 0;
	header.Date = "";
	header.Time = "";
	header.SoftVersion = 0;	% software version
	header.PatientID = "";
	header.ApOffset = 0;
	header.FOV = 0;
end