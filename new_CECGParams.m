function params = new_CECGParams()
    params = struct();
	params.ShowECG = false;
	params.Init = false;
	params.PreInit = false;
	params.ECGGain = 0;
	params.ECGPos = 0;
	params.WinBegin = 0;
	params.CurIndex = 0;
	params.CurFrame = 0;
	params.CurLine = 0;
	params.SamplesShown = 0;
	params.SampleSpacing = 0;
	params.RecordLength = 0;
	params.LineTime = 0;
	params.ECGValid = false;
	params.isGated= false;
end

